import "prim"

entry main (n: i64) (m: i64) (overlap_pct: f64) : ([][][]f64, [][]f64) =
  let (recs, points) = dummy_data n m overlap_pct
  let dum_recs = map (\i -> [[recs[i].min.x, recs[i].min.y], [recs[i].max.x, recs[i].max.y]]) (iota(length recs)) 
  let dum_points = map (\i -> [points[i].x, points[i].y]) (iota(length points))
  in (dum_recs, dum_points)

