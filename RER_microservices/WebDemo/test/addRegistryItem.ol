include "head.ol"

main {
  with( rq ) {
    .name = "Ferrara TPER";
    .city = "Ferrara";
    .location = "socket://localhost:9000"
  };
  addRegistryItem@Frontend( rq )()
}
