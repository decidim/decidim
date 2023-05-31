# frozen_string_literal: true

module Decidim
  module Upgrade
    class WysiwygMigrator
      class UndefinedColumnError < StandardError; end

      class << self
        def model_registry
          @model_registry ||= []
        end

        def register_model(klass, columns)
          if klass.is_a?(String)
            # Guard clause for when the module has not added to the instance.
            return unless Object.const_defined?(klass)

            klass = Object.const_get(klass)
          end

          columns.each do |col|
            raise UndefinedColumnError, "#{klass} does not have column named '#{col}'." unless klass.column_names.include?(col.to_s)
          end
          model_registry << { class: klass, columns: }
        end

        def batch_size
          @batch_size ||= 100
        end

        def batch_range(idx, data)
          start = idx * batch_size
          (start + 1)..(start + data.count)
        end

        def update_records_batches(query, columns, value_convert)
          query.in_batches(of: batch_size).each_with_index do |relation, idx|
            data = convert_model_data(relation, columns, &value_convert)
            next if data.empty?

            yield relation.klass, batch_range(idx, data) if block_given?

            # We are not using `update(data.keys, data.values)` here because
            # we want to bypass the overridden model methods, to be able to
            # update the data efficiently.
            data.each do |id, values|
              relation.klass.find(id).update_columns(values) # rubocop:disable Rails/SkipsModelValidations
            end
          end
        end

        def convert_model_data(relation, columns)
          {}.tap do |converted|
            relation.pluck(:id, *columns).map do |data|
              record_data = {}
              columns.each_with_index do |column, idx|
                value = data[idx + 1]
                record_data[column.to_s] = yield value, column
              end

              converted[data[0]] = record_data
            end
          end
        end

        # This is just a simplification method to avoid extending the cyclomatic
        # complexity of the settings hash value update lambda. In case a subkey
        # is given, the value of that key in the given hash will be yielded. If
        # no subkey is given, the hash itself is yielded. This allows us to
        # avoid repeating the same code twice in the `update_settings` method
        # depending on the depth of the hash we want to manage.
        def hash_subkey(hash, subkey = nil)
          return if hash.blank?

          if subkey.nil?
            yield hash
          else
            return if hash[subkey.to_s].blank?

            yield hash[subkey.to_s]
          end
        end

        def update_models(&)
          model_registry.each do |model|
            update_records_batches(
              model[:class],
              model[:columns],
              ->(value, _column) { convert(value) },
              &
            )
          end
        end

        def update_settings(query, keys, &)
          keys = { nil => keys } unless keys.is_a?(Hash)

          update_records_batches(
            query,
            [:settings],
            lambda do |settings, _column|
              keys.each do |key, definition|
                definition = { type: :single, keys: definition } unless definition.is_a?(Hash)

                hash_subkey(settings, key) do |current|
                  subkeys = definition[:type] == :multi ? current.keys : [nil]
                  subkeys.each do |subkey|
                    hash_subkey(current, subkey) do |attrs|
                      definition[:keys].each do |attribute|
                        attrs[attribute.to_s] = convert(attrs[attribute.to_s])
                      end
                      attrs
                    end
                  end
                end
              end

              settings
            end,
            &
          )
        end

        def editor_attributes_for(manifest)
          editor_attributes = { global: [], step: [] }
          editor_attributes.keys.each do |type|
            manifest.settings(type).attributes.each do |key, attribute|
              editor_attributes[type] << key.to_s if attribute.editor
            end
            editor_attributes.delete(type) if editor_attributes[type].blank?
          end
          editor_attributes
        end

        def update_component_settings
          Decidim.component_manifests.each do |manifest|
            editor_attributes = editor_attributes_for(manifest)
            next if editor_attributes.blank?

            # The step settings are stored in the DB with the key name in plural
            # format which is why we change it here. The `editor_attributes_for`
            # returns that key in singular format because this is how it it is
            # known by the manifest. Also, we need to define the type of the
            # settings values as step settings are stored in multi-dimensional
            # hash where each value contains settings for the defined step.
            keys = {}
            keys[:global] = { type: :single, keys: editor_attributes[:global] } if editor_attributes[:global].present?
            keys[:steps] = { type: :multi, keys: editor_attributes[:step] } if editor_attributes[:step].present?

            update_settings(
              Decidim::Component.where(manifest_name: manifest.name),
              keys
            ) do |_klass, range|
              yield manifest.name, range if block_given?
            end
          end
        end

        def convert(content)
          if content.is_a?(Hash)
            content.transform_values { |v| convert(v) }
          else
            new(content).run
          end
        end
      end

      def initialize(content)
        @doc = Nokogiri::HTML5.parse("")
        @content = content
      end

      def run
        return content unless content

        content_doc = Nokogiri::HTML5.parse(content)
        content_root = content_doc.at("//body")
        return content if content_root.children.empty?
        return content if content_root.children.length == 1 && content_root.children.first.name == "text"

        root = doc.at("//body")
        content_root.children.each do |node|
          append_node(root, convert_node(node))
        end
        root.inner_html
      end

      private

      attr_reader :doc, :content

      def append_node(parent, node)
        if node.is_a?(Array)
          node.each { |sub| append_node(parent, sub) }
        else
          parent.add_child node
        end
      end

      def convert_node(node)
        case node.name
        when "p"
          convert_paragraph(node)
        when "img"
          convert_image(node)
        when "ul", "ol"
          convert_list(node)
        when "iframe"
          convert_iframe(node)
        when "blockquote"
          convert_blockquote(node)
        when "code"
          convert_code(node)
        else
          node
        end
      end

      def convert_paragraph(paragraph)
        result = []
        parent = Nokogiri::XML::Node.new(paragraph.name, doc)

        indent = detect_indent(paragraph)
        parent.add_class("editor-indent-#{indent}") if indent.positive?

        paragraph.children.each do |child|
          case child.name
          when "img", "code"
            if parent.children.any?
              result.push(parent)
              parent = Nokogiri::XML::Node.new(paragraph.name, doc)
            end

            result.push convert_node(child)
          else
            parent.add_child convert_node(child)
          end
        end

        result.push(parent) if parent.children.any?

        result
      end

      # Images with the new editor are wrapped in a wrapper div as follows:
      #   <div class="editor-content-image" data-image="">
      #     <img src="..." alt="">
      #   </div>
      #
      # We are also setting an empty `alt` attribute on the image tag to make it
      # consistent as the new editor allows defining the `alt` attributes.
      def convert_image(image)
        parent = Nokogiri::XML::Node.new("div", doc)
        parent.add_class("editor-content-image")
        parent.set_attribute("data-image", "")
        image.set_attribute("alt", "") if image["alt"].nil?
        parent.add_child(image)
        parent
      end

      # Quill.js did not support multi-level lists which is why it used a CSS
      # hack to make it visually look like the list has multiple levels. This
      # is not semantically correct but for users with no visual impairments it
      # worked fine.
      #
      # The list HTML generated by Quill.js looks as follows:
      #   <ul>
      #     <li>Level 1 - Item 1</li>
      #     <li class="ql-indent-1">Level 2 - Item 1</li>
      #     <li class="ql-indent-2">Level 3 - Item 1</li>
      #     <li class="ql-indent-3">Level 4 - Item 1</li>
      #     <li class="ql-indent-2">Level 3 - Item 2</li>
      #     <li class="ql-indent-1">Level 2 - Item 2</li>
      #     <li>Level 1 - Item 2</li>
      #     <li>Level 1 - Item 3</li>
      #   </ul>
      #
      # The correct structure for this with the TipTap editor is as follows:
      #   <ul>
      #     <li>
      #       <p>Level 1 - Item 1</p>
      #       <ul>
      #         <li>
      #           <p>Level 2 - Item 1</p>
      #            <ul>
      #              <li>
      #                <p>Level 3 - Item 1</p>
      #                <ul>
      #                   <li><p>Level 4 - Item 1</p></li>
      #                </ul>
      #              </li>
      #              <li><p>Level 3 - Item 2</p></li>
      #            </ul>
      #         </li>
      #         <li><p>Level 2 - Item 2</p></li>
      #       </ul>
      #     </li>
      #     <li><p>Level 1 - Item 2</p></li>
      #     <li><p>Level 1 - Item 3</p></li>
      #   </ul>
      #
      # Note that the `<p>` elements are not necessary in HTML but TipTap
      # requires them in order to make it possible to style the content within
      # the list elements.
      def convert_list(list)
        parent = Nokogiri::XML::Node.new(list.name, doc)

        create_item = lambda do
          li = Nokogiri::XML::Node.new("li", doc)
          paragraph = Nokogiri::XML::Node.new("p", doc)
          li.add_child(paragraph)
          [li, paragraph]
        end
        add_empty_child = lambda do |child_parent|
          li, paragraph = create_item.call
          child_parent.add_child(li)
          [li, paragraph]
        end

        li = paragraph = nil
        current_parent = parent
        current_level = 0
        list.children.each do |item|
          indent = detect_indent(item)
          if indent == current_level || li.nil?
            if item.child.name == "p"
              # This content has already been migrated so we do not need to
              # re-migrate it.
              append_node(current_parent, convert_node(item))
              next
            else
              li, paragraph = add_empty_child.call(current_parent)
            end
          end

          while indent > current_level
            sublist = Nokogiri::XML::Node.new(list.name, doc)
            li.add_child(sublist)
            li, paragraph = create_item.call
            sublist.add_child(li)

            current_level += 1
            current_parent = sublist
          end
          while indent < current_level
            current_level -= 1
            li = current_parent.parent
            current_parent = li.parent
            paragraph = li.child

            li, paragraph = add_empty_child.call(current_parent) if indent == current_level
          end

          item.children.each { |child| append_node(paragraph, convert_node(child)) }
        end

        parent
      end

      # Converts iframe embeds to the new format. We assume all iframes are
      # video embeds as this the only type of embed what Quill.js supported and
      # also the only type we support in TipTap when this migration was written.
      #
      # Old format:
      #   <iframe src="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
      #
      # New format:
      #   <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0">
      #     <div>
      #       <iframe src="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
      #     </div>
      #   </div>
      def convert_iframe(node)
        src = node["src"]
        title = node["title"]

        parent = Nokogiri::XML::Node.new("div", doc)
        parent.add_class("editor-content-videoEmbed")
        parent.set_attribute("data-video-embed", src)

        wrapper = Nokogiri::XML::Node.new("div", doc)
        parent.add_child(wrapper)

        iframe = Nokogiri::XML::Node.new(node.name, doc)
        iframe.set_attribute("src", src)
        iframe.set_attribute("title", title || "")
        iframe.set_attribute("frameborder", "0")
        iframe.set_attribute("allowfullscreen", "true")
        wrapper.add_child(iframe)

        parent
      end

      # Blockquotes have block level content, i.e. the content needs to be
      # wrapped in a `<p>` tag. In Quill.js the content used to be directly
      # inside the `<blockquote>` element.
      def convert_blockquote(node)
        # In case the node already contains a `<p>` element, it has been
        # migrated.
        return node if node.child.name == "p"

        parent = Nokogiri::XML::Node.new(node.name, doc)
        paragraph = Nokogiri::XML::Node.new("p", doc)
        parent.add_child(paragraph)

        node.children.each { |child| append_node(paragraph, convert_node(child)) }

        parent
      end

      # The code blocks are wrapped in a `<pre>`.
      #
      # The end result should look as follows:
      #   <pre>
      #     <code>{"foo": "bar"}</code>
      #   </pre>
      def convert_code(node)
        parent = Nokogiri::XML::Node.new("pre", doc)
        parent.add_child(node)

        parent
      end

      def detect_indent(node)
        node["class"]&.match(/^(ql|editor)-indent-([0-9]+)/)&.public_send(:[], 2).to_i
      end
    end
  end
end
