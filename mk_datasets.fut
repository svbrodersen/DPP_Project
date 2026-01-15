import "prim"

def dummy_data (n: i64) (m: i64) (overlap_pct: f64) : ([n]aabb, [m]point) =
  let seed = 2026
  let base_size = 4.0
  let recs =
    let split = (f64.i64 n) * (1.0 - overlap_pct)
    let recs =
      map (\i ->
             let i = f64.i64 i
             in if i < split
                then -- Half overlapping
                     let start = i * (base_size / 2)
                     in {min = vec (start, 0), max = vec (start + base_size, 0 + base_size)}
                else -- Rectangles fully overlap
                     let start = (base_size / 2)
                     in {min = vec (start, base_size + 1.0), max = vec (start + base_size, 2 * base_size + 1.0 )})
          (iota n)
    in recs
  let max_x_coord = (f64.i64 n) * base_size + base_size
  let max_y_coord = 2 * base_size 
  let eng = rng_engine.rng_from_seed [seed]
  let engs = rng_engine.split_rng (2 * m) eng
  let random_values =
    map (\i ->
           if i < m
           then let e = engs[i]
                let (_, v) = rand_f64.rand (0.0, max_x_coord) e
                in v
           else let e = engs[i]
                let (_, v) = rand_f64.rand (0.0, max_y_coord) e
                in v)
        (iota (2 * m))
  let points = map (\i -> vec (random_values[i], random_values[i + m])) (iota m)
  in (recs, points)

entry main (n: i64) (m: i64) (overlap_pct: f64) : ([][][]f64, [][]f64) =
  let (recs, points) = dummy_data n m overlap_pct
  let dum_recs = map (\i -> [[recs[i].min.x, recs[i].min.y], [recs[i].max.x, recs[i].max.y]]) (iota(length recs)) 
  let dum_points = map (\i -> [points[i].x, points[i].y]) (iota(length points))
  in (dum_recs, dum_points)

