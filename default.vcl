vcl 4.1;
import directors;
import std;

## Backends of cluster definition
backend node1 {
  .host = "varnish1";
  .port = "80";
  .probe = {
      .request =
          "HEAD / HTTP/1.1"
          "Host: varnish1"
          "Connection: close"
          "User-Agent: Varnish Health Probe";
      .interval  = 3s;
      .timeout   = 3s;
      .window    = 3;
      .threshold = 2;
  }
}

backend node2 {
  .host = "varnish2";
  .port = "80";
  .probe = {
      .request =
          "HEAD / HTTP/1.1"
          "Host: varnish2"
          "Connection: close"
          "User-Agent: Varnish Health Probe";
      .interval  = 3s;
      .timeout   = 3s;
      .window    = 3;
      .threshold = 2;
  }
}

backend node3 {
  .host = "varnish3";
  .port = "80";
  .probe = {
      .request =
          "HEAD / HTTP/1.1"
          "Host: varnish3"
          "Connection: close"
          "User-Agent: Varnish Health Probe";
      .interval  = 3s;
      .timeout   = 3s;
      .window    = 3;
      .threshold = 2;
  }
}

# Backends api definition
backend content {
    .host = "httpd";
    .port = "80";
}

sub vcl_init
{
  # Backends pool definitions (name, weight)
  new cluster = directors.hash();
  cluster.add_backend(node1, 1);
  cluster.add_backend(node2, 1);
  cluster.add_backend(node3, 1);
}

sub vcl_recv
{
  # Healthcheck probe response
  if (req.http.User-Agent == "Varnish Health Probe") {
    return (synth(200));
  }

  # Cluster backend selection by directors vmod hashish url
  set req.backend_hint = cluster.backend(req.url);
  set req.http.X-shard = req.backend_hint;

  # If the backend selected is me, backend is api
  if (req.http.X-shard == server.identity) {
    set req.backend_hint = content;
    //... logic
    return(hash);
  } else {
    return (pass);
  }
}

sub vcl_backend_response {

    # Cache set
    unset beresp.http.Cache-Control;
    unset beresp.http.Set-Cookie;

    if (beresp.status == 200 || beresp.status == 308 || beresp.status == 304) {
        set beresp.http.Cache-Control = "max-age=60";
        set beresp.ttl = 60s;

    }

    set beresp.http.ban-url = bereq.url;
    set beresp.http.ban-host = bereq.http.host;
}
