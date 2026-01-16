import "prim"
import "bvh"

def rangeQuery2dPerformant [n] [m] (recs: [n]aabb) (points: [m]point) : i32 =
  let contains point aabb = aabb_hit aabb point
  let bvh = bvh_mk recs
  let vals = map (\p -> bvh_hit (contains p) bvh) points
  in reduce (+) 0 (vals)

-- ==
-- entry: pbbsPerformant
-- compiled input @ data/1M.in
entry pbbsPerformant [n] (ps: [n][2]f64) : i32 =
  let split = 2 * (n // 3)
  let recs_split = ps[0:split]
  let recs =
    map (\i ->
           let (x1, y1, x2, y2) = (recs_split[i][0], recs_split[i][1], recs_split[i + 1][0], recs_split[i + 1][1])
           let p1 = (f64.min x1 x2, f64.min y1 y2)
           let p2 = (f64.max x1 x2, f64.max y1 y2)
           in {min = vec p1, max = vec p2})
        (0..2...split - 1)
  let points = (ps[split:n]) |> map (\a -> vec (a[0], a[1]))
  in rangeQuery2dPerformant recs points

-- ==
-- entry: defaultPerformant
-- notest compiled input @ data/1000_1000_0.0.in
-- notest compiled input @ data/1000_1000_0.25.in
-- notest compiled input @ data/1000_1000_0.5.in
-- notest compiled input @ data/1000_10000_0.0.in
-- notest compiled input @ data/1000_10000_0.25.in
-- notest compiled input @ data/1000_10000_0.5.in
-- notest compiled input @ data/1000_100000_0.0.in
-- notest compiled input @ data/1000_100000_0.25.in
-- notest compiled input @ data/1000_100000_0.5.in
-- notest compiled input @ data/1000_1000000_0.0.in
-- notest compiled input @ data/1000_1000000_0.25.in
-- notest compiled input @ data/1000_1000000_0.5.in
-- notest compiled input @ data/1000_10000000_0.0.in
-- notest compiled input @ data/1000_10000000_0.25.in
-- notest compiled input @ data/1000_10000000_0.5.in
-- notest compiled input @ data/10000_1000_0.0.in
-- notest compiled input @ data/10000_1000_0.25.in
-- notest compiled input @ data/10000_1000_0.5.in
-- notest compiled input @ data/10000_10000_0.0.in
-- notest compiled input @ data/10000_10000_0.25.in
-- notest compiled input @ data/10000_10000_0.5.in
-- notest compiled input @ data/10000_100000_0.0.in
-- notest compiled input @ data/10000_100000_0.25.in
-- notest compiled input @ data/10000_100000_0.5.in
-- notest compiled input @ data/10000_1000000_0.0.in
-- notest compiled input @ data/10000_1000000_0.25.in
-- notest compiled input @ data/10000_1000000_0.5.in
-- notest compiled input @ data/10000_10000000_0.0.in
-- notest compiled input @ data/10000_10000000_0.25.in
-- notest compiled input @ data/10000_10000000_0.5.in
-- notest compiled input @ data/100000_1000_0.0.in
-- notest compiled input @ data/100000_1000_0.25.in
-- notest compiled input @ data/100000_1000_0.5.in
-- notest compiled input @ data/100000_10000_0.0.in
-- notest compiled input @ data/100000_10000_0.25.in
-- notest compiled input @ data/100000_10000_0.5.in
-- notest compiled input @ data/100000_100000_0.0.in
-- notest compiled input @ data/100000_100000_0.25.in
-- notest compiled input @ data/100000_100000_0.5.in
-- notest compiled input @ data/100000_1000000_0.0.in
-- notest compiled input @ data/100000_1000000_0.25.in
-- notest compiled input @ data/100000_1000000_0.5.in
-- notest compiled input @ data/100000_10000000_0.0.in
-- notest compiled input @ data/100000_10000000_0.25.in
-- notest compiled input @ data/100000_10000000_0.5.in
-- notest compiled input @ data/1000000_1000_0.0.in
-- notest compiled input @ data/1000000_1000_0.25.in
-- notest compiled input @ data/1000000_1000_0.5.in
-- notest compiled input @ data/1000000_10000_0.0.in
-- notest compiled input @ data/1000000_10000_0.25.in
-- notest compiled input @ data/1000000_10000_0.5.in
-- notest compiled input @ data/1000000_100000_0.0.in
-- notest compiled input @ data/1000000_100000_0.25.in
-- notest compiled input @ data/1000000_100000_0.5.in
-- notest compiled input @ data/1000000_1000000_0.0.in
-- notest compiled input @ data/1000000_1000000_0.25.in
-- notest compiled input @ data/1000000_1000000_0.5.in
-- notest compiled input @ data/1000000_10000000_0.0.in
-- notest compiled input @ data/1000000_10000000_0.25.in
-- notest compiled input @ data/1000000_10000000_0.5.in
entry defaultPerformant (recs: [][2][2]f64) (points: [][2]f64) : i32 =
  let n = length recs
  let m = length points
  let recs =
    map (\i ->
           let xl = recs[i][0][0]
           let yl = recs[i][0][1]
           let xu = recs[i][1][0]
           let yu = recs[i][1][1]
           in {min = vec (xl, yl), max = vec (xu, yu)})
        (iota n)
  let points =
    map (\i ->
           let x = points[i][0]
           let y = points[i][1]
           in vec (x, y))
        (iota m)
  in rangeQuery2dPerformant recs points
