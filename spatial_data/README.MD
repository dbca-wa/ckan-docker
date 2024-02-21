# Spatial Data

This directory is used to store GeoJSON files that will be loaded from docker entrypoint file `02_setup_dbca.sh` using the CLI command `ckan -c $CKAN_INI dbca load_spatial_data` if the mapping exists in `ckanext.dbca.spatial_data_mapping`.

## Usage

To add a new GeoJSON file, simply place it in this directory. The container will automatically load the file if there is a corresponding mapping defined in `ckanext.dbca.spatial_data_mapping`.

Please ensure that the GeoJSON file follows the correct format and contains valid spatial data.

## Mapping

The mapping between the GeoJSON files and the data fields in the CKAN database is defined in the `ckanext.dbca.spatial_data_mapping` configuration. Make sure to update the mapping accordingly if you add or modify any GeoJSON files.

Each mapping consists of a filename, layer field, a code field, and a name field.

The mappings are defined as a dictionary where the key is the filename of the GeoJSON file and the value is another dictionary containing the layer, code, and name fields.

Example:
```
{
    "ibra.geojson": {"layer": "IBRA Regions", "code":"IWA_REG_CODE_7", "name":"IWA_REG_NAME_7"}, 
    "ibra-sub.geojson": {"layer": "IBRA Subregions)", "code":"IWA_SUB_CODE_7", "name":"IWA_SUB_NAME_7"}, 
    "imcra.geojson": {"layer": "IMCRA Regions", "code": "MESO_ABBR", "name":"MESO_NAME"}, 
    "lga-wa.geojson": {"layer": " Local Government Areas", "code":"LGA_TYPE", "name":"LGA_LGA_NAME"}, 
    "tenure.geojson": {"layer": "DBCA Managed Tenure", "code":"LEG_TENURE", "name":"LEG_NAME"}
}
```
