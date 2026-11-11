# stats19-to-features

[DfT road safety open data](https://www.gov.uk/government/statistical-data-sets/road-safety-open-data) (A.K.A. STATS19) for Sheffield, downloaded, formatted, and converted to a GeoPackage via the [{stats19}](https://docs.ropensci.org/stats19/) R package.

Currently only processing the last 5 years of data (2021 to 2025 inclusive). The output file is called `stats19_last5yrs_sheffield.gpkg`.

Updating to the latest version of the {stats19} package is recommended.  

The DfT data is provided in 3 tables joined on `collision_index`:  

1. **Collision** (referred to as "accident" in earlier years) - Lat & Long, plus it has the LSOA of the collision.  
1. **Casualty** - No Lat & Long, but LSOA of casualty.  
1. **Vehicle** - No Lat & Long, but LSOA of driver.  

We've filtered and joined the data on collisions in Sheffield. Therefore, there are some casualties and vehicle drivers that reside outside of Sheffield in the data, whereas Sheffield casualties and vehicle drivers involved in collisions that occurred outside of Sheffield are not included in the data.   

The most significant STATS19 data quality issues are from differences in reporting by different police authorities, which is not an issue for our Sheffield only dataset. However, there are other data quality issues that the SCC Road Safety team are aware of.  