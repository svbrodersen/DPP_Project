import "prim"

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

def rangeQuery2dNaive [n] [m] (recs: [n]aabb) (points: [m]point) : i64 =
  let vals = map (\i -> 
                  let (xl, yl) = (recs[i].min.x, recs[i].min.y)
                  let (xu, yu) = (recs[i].max.x, recs[i].max.y)
                  let vals = map (\j -> 
                    let (x, y) = (points[j].x, points[j].y)
                    in if (x >= xl) && (y >= yl) && (x <= xu) && (y <= yu) then 1 else 0) (iota m)
                  in (reduce (+) 0 vals)) (0..2...(n-1))
  in reduce (+) 0 vals

entry main0 [n] (ps : [n][2]f64) : i64 =
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
  in rangeQuery2dNaive recs points

-- ==
-- entry: main2
-- notest compiled input @ data/dataset_100_0.0.in
-- notest compiled input @ data/dataset_100_0.1.in
-- notest compiled input @ data/dataset_100_0.2.in
-- notest compiled input @ data/dataset_100_0.3.in
-- notest compiled input @ data/dataset_100_0.4.in
-- notest compiled input @ data/dataset_100_0.5.in
-- notest compiled input @ data/dataset_1000_0.0.in
-- notest compiled input @ data/dataset_1000_0.1.in
-- notest compiled input @ data/dataset_1000_0.2.in
-- notest compiled input @ data/dataset_1000_0.3.in
-- notest compiled input @ data/dataset_1000_0.4.in
-- notest compiled input @ data/dataset_1000_0.5.in
-- notest compiled input @ data/dataset_10000_0.0.in
-- notest compiled input @ data/dataset_10000_0.1.in
-- notest compiled input @ data/dataset_10000_0.2.in
-- notest compiled input @ data/dataset_10000_0.3.in
-- notest compiled input @ data/dataset_10000_0.4.in
-- notest compiled input @ data/dataset_10000_0.5.in
-- notest compiled input @ data/dataset_100000_0.0.in
-- notest compiled input @ data/dataset_100000_0.1.in
-- notest compiled input @ data/dataset_100000_0.2.in
-- notest compiled input @ data/dataset_100000_0.3.in
-- notest compiled input @ data/dataset_100000_0.4.in
-- notest compiled input @ data/dataset_100000_0.5.in
-- notest compiled input @ data/dataset_1000000_0.0.in
-- notest compiled input @ data/dataset_1000000_0.1.in
-- notest compiled input @ data/dataset_1000000_0.2.in
-- notest compiled input @ data/dataset_1000000_0.3.in
-- notest compiled input @ data/dataset_1000000_0.4.in
-- notest compiled input @ data/dataset_1000000_0.5.in
-- notest compiled input @ data/dataset_10000000_0.0.in
-- notest compiled input @ data/dataset_10000000_0.1.in
-- notest compiled input @ data/dataset_10000000_0.2.in
-- notest compiled input @ data/dataset_10000000_0.3.in
-- notest compiled input @ data/dataset_10000000_0.4.in
-- notest compiled input @ data/dataset_10000000_0.5.in
entry main2 n m (recs: [n][2][2]f64) (points: [m][2]f64) : i64 =
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
  in rangeQuery2dNaive recs points
