import "lib/github.com/athas/vector/vspace"
import "lib/github.com/diku-dk/cpprandom/random"

module rng_engine = minstd_rand
module rand_f64 = uniform_real_distribution f64 u32 rng_engine

module vec2 = mk_vspace_2d f64
type vec2 = vec2.vector

type point = vec2

-- A convenient alias so we don't have to indicate the fields all the
-- time.
def vec (x, y) : vec2 = {x, y}

-- | Axis-aligned bounding box.
type aabb = {min: vec2, max: vec2}

def surrounding_box (box0: aabb) (box1: aabb) : aabb =
  let small =
    vec ( f64.min box0.min.x box1.min.x
        , f64.min box0.min.y box1.min.y
        )
  let big =
    vec ( f64.max box0.max.x box1.max.x
        , f64.max box0.max.y box1.max.y
        )
  in {min = small, max = big}

def aabb_hit ({min, max}: aabb) (p: point) : bool =
  min.x <= p.x && min.y <= p.y && max.x >= p.x && max.y >= p.y

def aabb_center ({min, max}: aabb) =
  { x = min.x + (max.x - min.x) / 2
  , y = min.y + (max.y - min.y) / 2
  }

def dummy_data (n: i64) (m: i64) (scale_pct: f64) : ([n]aabb, [m]point) =
  let seed = 2026
  let eng = rng_engine.rng_from_seed [seed]
  let engs = rng_engine.split_rng (2 * n + 2 * m) eng
  let base_size = 2.0
  let region_scale = 1.0 - scale_pct
  let recs =
    -- Strategy: Place rectangles in a way that correlates with overlap_pct
    -- Higher overlap_pct -> rectangles placed closer together in a smaller region
    -- Lower overlap_pct -> rectangles spread out more

    -- Calculate region size to achieve desired overlap
    -- With no overlap: region should be sqrt(n) * base_size
    -- With high overlap: region should be smaller
    -- Heuristic: region_scale = 1.0 means minimal overlap
    --            region_scale closer to 0 means high overlap
    let region_size = ((f64.i64 n)) * base_size * region_scale
    in map (\i ->
              let i = i * 2
              let eng_x = engs[i]
              let eng_y = engs[i + 1]
              let (_, x) = rand_f64.rand (0.0, region_size) eng_x
              let (_, y) = rand_f64.rand (0.0, region_size) eng_y
              in {min = vec (x, y), max = vec (x + base_size, y + base_size)})
           (iota n)
  -- Generate random points (unchanged from original)
  let max_coord =
    if n == 0
    then 10.0
    else let region_scale = (1.0 - scale_pct)
         let region_size = ((f64.i64 n)) * base_size * region_scale
         in region_size + 2.0
  let random_values =
    map (\e ->
           let (_, v) = rand_f64.rand (0.0, max_coord) e
           in v)
        engs[2 * n:]
  let is = map (* 2) (iota m)
  let points = map (\i -> vec (random_values[i], random_values[i + 1])) is
  in (recs, points)
