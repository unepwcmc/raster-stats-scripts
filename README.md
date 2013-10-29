### Simple country based query utilities for [raster-stats](https://github.com/unepwcmc/raster-stats).

Use it as a module in other ruby code:

```rb
require './raster_stats_query_module'
```

or directly in a shell:

```sh
ruby get_raster_stats.rb --help

# To get results for all countries on restoration potential:
ruby get_raster_stats.rb -o percentage -i 6,7,8,9,11
```
