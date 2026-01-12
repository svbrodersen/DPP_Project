import "prim"
import "bvh"

--
-- ==
-- entry: main
-- compiled input @ data/10.in
-- output { 23i32 }
-- compiled input @ data/100.in
-- output { 1208i32 }
-- compiled input @ data/1000.in
-- output { 123068i32 }
-- compiled input @ data/10000.in
-- output { 11255843i32 }

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
           let p1 = (recs_split[i][0], recs_split[i][1])
           let p2 = (recs_split[i + 1][0], recs_split[i][1])
           in {min = vec p1, max = vec p2})
        (0..2...split - 1)
  let points = (ps[split:n]) |> map (\a -> vec (a[0], a[1]))
  in rangeQuery2dPerformant recs points
