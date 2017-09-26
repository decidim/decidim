## How to use the CSV importer

Upload a CSV file with the following headers:

- `result_id`
- `decidim_category_id`
- `decidim_scope_id`
- `parent_id`
- `external_id`
- `parent_external_id`
- `start_date`
- `end_date`
- `decidim_accountability_status_id`
- `progress`
- `proposal_ids`
- `title_ca`
- `title_es`
- `title_en`
- `description_ca`
- `description_es`
- `description_en`

You can download [empty_example.csv](empty_example.csv) from this folder and fill it with your data. 

If there's any error on any of the CSV rows the file will not be imported at all. You will get the error messages so you can fix the file and upload it again.  

### Description of CSV columns

#### `result_id` 
It's the internal ID of the result in Decidim.

If it's present the importer will try to find the result with that ID and update it. If the result with that ID is not found you will get an error.

If it desn't have a value (and there's no value for `external_id` in this row, as explained later) the importer will try to create a new result.


#### `decidim_category_id`
ID in Decidim of the category for this result


#### `decidim_scope_id`
ID in Decidim of the scope for this result


#### `parent_id`
If this result belongs to another result, the ID of the parent result.


#### `external_id`
An ID for this result that is used in an external system, for example the city council project tracking system.

If this column has a value and the `result_id` column doesn't have one, the importer will try to find the result with this `external_id` and update it with the values of this row. If it's not found it will create a new result.


#### `parent_external_id`
This doesn't correspond to a field in the result for this row, it's meant to complement the `parent_id` column. When `parent_id` is not present in this row but `parent_external_id` is, it will be used to look for the parent result for this row by its `external_id` and set it as the parent for this row result.


#### `start_date`
Start date, in a format parseable by `Date.parse`, for example DD/MM/YYYY.


#### `end_date`
End date, in a format parseable by `Date.parse`, for example DD/MM/YYYY.


#### `decidim_accountability_status_id`
ID in Decidim of the Status for this result


#### `progress`
Number representing the progress for this result. 

If the status set for this row has an associated progress value progress for this result will be set to that, ignoring this value.

For results that have children the progress will be calculated and stored as the mean of all its children, and this value will have no effect.


#### `proposal_ids`
This should be a list of the IDs of the proposals in Decidim, separated by semicolons.


#### `title` and `description`
For the  `title` and `description` columns you should add one column per available locale, with the `_locale` suffix. You need at least the values for the default locale. The values for the default locale will be copied to the missing ones.


## Example use cases

### PAM use case

For the PAM process in Decidim Barcelona, there are already results in Decidim, but the projects (child results) are being tracked in an external system. This systems has its own IDs for first level results (already in Decidim) and second level results (projects, still not created in Decidim). 

This importer can be used to import those results without having to fill in the internal Decidim IDs in the CSV file. 

In a first pass the existing results will have to be updated to store the external system ID in the `external_id` field. 

Then in the CSV to create the second level results (projects), instead of filling the `parent_id` column with the internal Decidim ID, fill in the `parent_external_id` column with the ID in the external project tracking system, and the parent result will be found by its `external_id` field and the new result created as a child of that result.

If you want to update existing results that already have an `external_id` set with the value of the external system ID, in the CSV you can fill in the `external_id`  column instead of filling in the `result_id` column and the importer will find the result by its `external_id` and update it. 


