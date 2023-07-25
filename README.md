
# Varnish sharding cluster

## About The Project

This project has been built to enjoy with free varnish cluster solution. Is based in object sharding and backend self-routing.

### Installation

The project contains three instances of varnish and simple apache within docker so the first time it is only necessary to do a:

```docker-compose up --build```

## Usage

There are three varnish instances with the same config, four backends.

Backends **varnish1**, **varnish2** and **varnish3** are the cluster backends.

Backend **content** is the api with two simple html files.

You can make request to the varnish hosts, for example:

To varnish3
```
curl -s  http://0.0.0.0:8093/index.html
```

Ports:
* 8091 is varnish1
* 8092 is varnish2 
* 8093 is varnish3

You can view varnish activity with varnislog in the docker container, example:
```
docker exec -ti varnish3  varnishlog
```

You can stop and instance to force cluster node down:
```
docker-compose stop varnish1 varnish2
```

Or start to recover nodes activity:
```
docker-compose start varnish1 varnish2
```

## Related links

* [3-tips-to-boost-the-performance-of-your-varnish-cache](https://nbeguier.medium.com/3-tips-to-boost-the-performance-of-your-varnish-cache-3f4ce44be3c1)
* [creating-self-routing-varnish-cluster](https://info.varnish-software.com/blog/creating-self-routing-varnish-cluster)
* [vmod_directors](https://varnish-cache.org/docs/trunk/reference/vmod_directors.html)
* [users-guide/vcl-backends.html](https://varnish-cache.org/docs/4.1/users-guide/vcl-backends.html?highlight=health%20check)

