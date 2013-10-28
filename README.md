### Simple country based query utilities for the [raster-stats](https://github.com/unepwcmc/raster-stats) application.

Use it as a module in other ruby code:

```rb
require './raster_stats_query_module'
```

or directly in a shell:

```sh
ruby get_raster_stats.rb --help
ruby get_raster_stats.rb -o sum -c MG -i 1,2,3,4 -o percentage -u http://10.1.1.121:3000/
```
