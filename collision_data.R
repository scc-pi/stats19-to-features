# install.packages("stats19")
library(stats19)
library(tidyverse)
library(lubridate)
library(here)
library(sf)

latest_year <- 2025
number_of_years <- 5
years <- seq(latest_year - number_of_years + 1, latest_year)

# DfT road traffic casualty database (STATS19) is provided in 3 main tables:
#   1. collision (the only one with Lat & Long)
#   2. casualty  
#   3. vehicle  

# ** 1. COLLISION **

sf_collision_raw <- get_stats19(
  year = years,
  type = "collision",
  data_dir = here("data", "raw"),
  ask = FALSE,
  output_format = "sf"
)

# Filter on Sheffield - local authority fields are not consistently populated
# across years (e.g. local_authority_district is NA for 2024)
sf_collision_sheffield <- sf_collision_raw |>
  filter(
    if_any(
      c(
        local_authority_district, 
        local_authority_ons_district, 
        local_authority_highway
      ),
      ~ !is.na(.) & . == "Sheffield"
    )
  )

# Add a new column with the day of the week as a number e.g. Monday = 1
sf_collision_sheffield <- sf_collision_sheffield |> 
  mutate(day_of_week_num = wday(date, week_start = 1), .after = day_of_week)

# Specify name and location of the GeoPackage file
output_dir <- here()
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_file <- file.path(
  output_dir, 
  str_c("stats19_last", number_of_years,"yrs_sheffield.gpkg")
)

# Write one layer to our GeoPackage file
st_write(
  sf_collision_sheffield, 
  output_file, 
  layer = "collision", 
  delete_dsn = FALSE,
  delete_layer = TRUE
)

# ** 2. CASUALTY **  

df_casualty_raw <- get_stats19(
  year = years,
  type = "casualty",
  data_dir = here("data", "raw"),
  ask = FALSE,
  output_format = "tibble"
)

# Join on Sheffield collisions
df_casualty_sheffield <- df_casualty_raw |>
  inner_join(select(sf_collision_sheffield, collision_index))

st_write(
  select(df_casualty_sheffield, -geometry), 
  output_file, 
  layer = "casualty", 
  delete_dsn = FALSE,
  delete_layer = TRUE
)

# ** 3. VEHICLE **

df_vehicle_raw <- get_stats19(
  year = years,
  type = "Vehicle",
  data_dir = here("data", "raw"),
  ask = FALSE,
  output_format = "tibble"
)

# Join on Sheffield collisions
df_vehicle_sheffield <- df_vehicle_raw |>
  inner_join(select(sf_collision_sheffield, collision_index))

st_write(
  select(df_vehicle_sheffield, -geometry), 
  output_file, 
  layer = "vehicle", 
  delete_dsn = FALSE,
  delete_layer = TRUE
)
