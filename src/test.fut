import "rangeQuery2dNaive"
import "rangeQuery2dPerformant"
import "prim"
import "bvh"


-- == entry main
-- compiled input @ data/1000_1000_0.0.in
-- output { true }
-- compiled input @ data/1000_1000_0.25.in
-- output { true }
-- compiled input @ data/1000_1000_0.5.in
-- output { true }
-- compiled input @ data/1000_10000_0.0.in
-- output { true }
-- compiled input @ data/1000_10000_0.25.in
-- output { true }
-- compiled input @ data/1000_10000_0.5.in
-- output { true }
-- compiled input @ data/1000_100000_0.0.in
-- output { true }
-- compiled input @ data/1000_100000_0.25.in
-- output { true }
-- compiled input @ data/1000_100000_0.5.in
-- output { true }
-- compiled input @ data/1000_1000000_0.0.in
-- output { true }
-- compiled input @ data/1000_1000000_0.25.in
-- output { true }
-- compiled input @ data/1000_1000000_0.5.in
-- output { true }
-- compiled input @ data/1000_10000000_0.0.in
-- output { true }
-- compiled input @ data/1000_10000000_0.25.in
-- output { true }
-- compiled input @ data/1000_10000000_0.5.in
-- output { true }
entry main (recs: [][2][2]f64) (points: [][2]f64) : bool =
  let n = length recs
  let m = length points
  let recs = map (\i ->
    let xl = recs[i][0][0]
    let yl = recs[i][0][1]
    let xu = recs[i][1][0]
    let yu = recs[i][1][1]
    in {min = vec(xl, yl), max = vec(xu, yu)}
  ) (iota n)
  let points = map (\i ->
    let x = points[i][0]
    let y = points[i][1]
    in vec(x, y)
  ) (iota m)
  let res0 = rangeQuery2dPerformant recs points
  let res1 = rangeQuery2dNaive recs points
  in res0 == res1
