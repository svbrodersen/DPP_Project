import "prim"
import "bvh"

def rangeQuery2dPerformant [n] [m] (recs: [n]aabb) (points: [m]point) : i32 =
  let contains point aabb = aabb_hit aabb point
  let bvh = bvh_mk recs
  let vals = map (\p -> bvh_hit (contains p) bvh) points
  in reduce (+) 0 (vals)

entry main [n] (ps : [n][2]f64) : i64 =
  let split = 2 * (n // 3)
  let recs_split = ps[0:split]
  let recs = map (\i -> 
    let (x1, y1) = (recs_split[i][0], recs_split[i][1])
    let (x2, y2) = (recs_split[i+1][0], recs_split[i][1])
    in {min = vec x1 y1, max = vec x2 y2} ) (0..2...split-1)
  let points = ps[split:n] |> map vec
  in rangeQuery2dPerformant recs points
