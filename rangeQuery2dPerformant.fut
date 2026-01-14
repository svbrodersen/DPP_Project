import "prim"
import "bvh"

--
-- ==
-- entry: main
-- nobench compiled input @ data/10.in
-- output { 23i32 }
-- nobench compiled input @ data/100.in
-- output { 1208i32 }
-- nobench compiled input @ data/1000.in
-- output { 123068i32 }
-- nobench compiled input @ data/10000.in
-- output { 11255843i32 }
-- notest compiled input @ data/1M.in
-- notest compiled input @ data/10M.in

def rangeQuery2dPerformant [n] [m] (recs: [n]aabb) (points: [m]point) : i32 =
  let contains point aabb = aabb_hit aabb point
  let bvh = bvh_mk recs
  let vals = map (\p -> bvh_hit (contains p) bvh) points
  in reduce (+) 0 (vals)

entry main [n] (ps: [n][2]f64) : i32 =
  let split = 2 * (n // 3)
  let recs_split = ps[0:split]
  let recs =
    map (\i ->
           let (x1, y1, x2, y2) = (recs_split[i][0], recs_split[i][1], recs_split[i + 1][0], recs_split[i+1][1])
           let p1 = (f64.min x1 x2, f64.min y1 y2)
           let p2 = (f64.max x1 x2, f64.max y1 y2)
           in {min = vec p1, max = vec p2})
        (0..2...split - 1)
  let points = (ps[split:n]) |> map (\a -> vec (a[0], a[1]))
  in rangeQuery2dPerformant recs points
