--
-- ==
-- compiled input @ data/10.in
-- output { 21i64 }
-- compiled input @ data/100.in
-- output { 1167i64 }
-- compiled input @ data/1000.in
-- output { 121762i64 }
-- compiled input @ data/10000.in
-- output { 11208238i64 }

def rangeQuery2d [n] [m] (recs: [n][2]f64) (points: [m][2]f64) : i64 =
  let sum = loop sum = 0 for i in 0..2...(n-1)  do
                  let (x1, y1) = (recs[i][0], recs[i][1])
                  let (x2, y2) = (recs[i+1][0], recs[i+1][1])
                  let xl = f64.min x1 x2
                  let yl = f64.min y1 y2
                  let xu = f64.max x1 x2
                  let yu = f64.max y1 y2
                  let vals = map (\j -> 
                    let (x, y) = (points[j][0], points[j][1])
                    in if (x > xl) && (y > yl) && (x < xu) && (y < yu) then 1 else 0) (iota m)
                  in sum + (reduce (+) 0 vals)
  in sum

entry main [n] (ps : [n][2]f64) : i64 =
  let split = 2 * (n // 3)
  let recs = ps[0:split]
  let points = ps[split:n]
  in rangeQuery2d recs points


