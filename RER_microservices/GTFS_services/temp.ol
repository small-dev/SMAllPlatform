include "console.iol"
include "string_utils.iol"
include "time.iol"

main {
  st = "20161201";
  st.length = 2;
  splitByLength@StringUtils( st )( result )
}
