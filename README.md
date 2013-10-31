### Simple country based query utilities for [raster-stats](https://github.com/unepwcmc/raster-stats).

Use it as a module in other ruby code:

```rb
require './raster_stats_query_module'
```

or directly in a shell:

```sh
ruby get_raster_stats.rb --help

# To get the percentage for all countries on restoration potential:
# 6  = mosaic
# 7  = wide scale
# 8  = remote
# 9  = agricultural
# 11 = no value
ruby get_raster_stats.rb -o percentage -i 6,7,8,9,11

# To write the percentage for all countries on forest status to a forest_status.JSON file:
# 10 = fragmented forest
# 12 = intact forest
# 13 = partly deforested
# 14 = deforested
# 15 = no value
ruby get_raster_stats.rb -o percentage -i 10,12,13,14,15 -f forests

# To get the total tonnes of carbon for Canada:
# 16 = carbon (it is in mollewide!)
ruby get_raster_stats.rb -o sum -i 16 -c CA -m
```



