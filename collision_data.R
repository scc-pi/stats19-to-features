# install.packages("stats19")
library(stats19)
library(tidyverse)
library(here)
library(sf)

latest_year <- 2024
number_of_years <- 4
years <- seq(latest_year - number_of_years + 1, latest_year)

# DfT road traffic casualty database (STATS19) is provided in 3 main tables:
#   1. collision
#   2. casualty  
#   3. vehicle  

# ** 1. COLLISION **

collision_raw <- get_stats19(
  year = years,
  type = "collision",
  data_dir = here("data", "raw"),
  ask = FALSE,
  output_format = "sf"
)

# stopifnot(
#   "Collision data missing for some requested years" =
#     setequal(unique(collision_raw$collision_year), years)
# )

# Filter on Sheffield - local authority fields are not consistently populated
# across years (e.g. local_authority_district is NA for 2024)
collision_sheffield <- collision_raw |>
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

output_dir <- here("data", "processed")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_file <- file.path(
  output_dir, 
  str_c("sheffield_stats19_last", number_of_years,"yrs.gpkg")
)

st_write(
  collision_sheffield, 
  output_file, 
  layer = "collision", 
  delete_dsn = TRUE
)

# ** 2. CASUALTY **  

casualty_raw <- get_stats19(
  year = years,
  type = "casualty",
  data_dir = here("data", "raw"),
  ask = FALSE,
  output_format = "sf"
)

# Join on Sheffield collisions
casualty_sheffield <- casualty_raw |>
  inner_join(select(collision_sheffield, collision_index))

st_write(
  casualty_sheffield, 
  output_file, 
  layer = "casualty", 
  delete_dsn = TRUE
)

# ** 3. VEHICLE **

vehicle_raw <- get_stats19(
  year = years,
  type = "Vehicle",
  data_dir = here("data", "raw"),
  ask = FALSE,
  output_format = "tibble"
)

# Join on Sheffield collisions
vehicle_sheffield <- vehicle_raw |>
  inner_join(select(collision_sheffield, collision_index))

st_write(
  vehicle_sheffield, 
  output_file, 
  layer = "vehicle", 
  delete_dsn = TRUE
)
