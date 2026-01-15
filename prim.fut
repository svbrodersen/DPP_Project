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

