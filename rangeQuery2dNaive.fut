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

def rangeQuery2dNaive [n] [m] (recs: [n][2]f64) (points: [m][2]f64) : i64 =
  let vals = map (\i -> 
                  let (x1, y1) = (recs[i][0], recs[i][1])
                  let (x2, y2) = (recs[i+1][0], recs[i+1][1])
                  let xl = f64.min x1 x2
                  let yl = f64.min y1 y2
                  let xu = f64.max x1 x2
                  let yu = f64.max y1 y2
                  let vals = map (\j -> 
                    let (x, y) = (points[j][0], points[j][1])
                    in if (x >= xl) && (y >= yl) && (x <= xu) && (y <= yu) then 1 else 0) (iota m)
                  in (reduce (+) 0 vals)) (0..2...(n-1))
  in reduce (+) 0 vals

entry main0 [n] (ps : [n][2]f64) : i64 =
  let split = 2 * (n // 3)
  let recs = ps[0:split]
  let points = ps[split:n]
  in rangeQuery2dNaive recs points


-- ==
-- entry: main1
-- input {100000i64}
-- input {1000000i64} 
-- input {10000000i64}
-- input {100000000i64}
entry main1 (n: i64) : i64 = 
  let ps =
    tabulate_2d n 2 (\i _j ->
                       if i >= 2 * (n // 3)
                       then f64.i64 (n - i)
                       else f64.i64 i)
  let split = 2 * (n // 3)
  let recs = ps[0:split]
  let points = (ps[split:n]) 
  in rangeQuery2dNaive recs points
  
