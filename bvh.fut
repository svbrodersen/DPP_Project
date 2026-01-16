import "lib/github.com/diku-dk/sorts/radix_sort"
import "radixtree"
import "prim"

-- Spreads 32 bits into 64 bits with 1-bit gaps (leaving space for another 32-bit value)
def expand_bits (v: u32) : u64 =
  let v = u64.u32 v
  let v = (v | (v << 16)) & 0x0000FFFF0000FFFF
  let v = (v | (v << 8))  & 0x00FF00FF00FF00FF
  let v = (v | (v << 4))  & 0x0F0F0F0F0F0F0F0F
  let v = (v | (v << 2))  & 0x3333333333333333
  let v = (v | (v << 1))  & 0x5555555555555555
  in v

def morton_2D {x, y} : u64 =
  -- Scale and clamp to 32-bit range (0 - 4294967295)
  let x_uint = u32.f64 (f64.min (f64.max (x * 4294967295.0) 0.0) 4294967295.0)
  let y_uint = u32.f64 (f64.min (f64.max (y * 4294967295.0) 0.0) 4294967295.0)

  let xx = expand_bits x_uint
  let yy = expand_bits y_uint

  -- Interleave the bits
  in (xx << 1) | yy

type ptr = #leaf i32 | #inner i32

type inner = {aabb: aabb, left: ptr, right: ptr, parent: i32}

type~ bvh [n] = {L: [n]aabb, I: []inner}

def bvh_mk [n] (ts: [n]aabb) : bvh [n] =
  let centers = map (aabb_center) ts
  let x_max = f64.maximum (map (.x) centers)
  let y_max = f64.maximum (map (.y) centers)
  let x_min = f64.minimum (map (.x) centers)
  let y_min = f64.minimum (map (.y) centers)
  let normalize {x, y} =
    { x = (x - x_min) / (x_max - x_min)
    , y = (y - y_min) / (y_max - y_min)
    }
  let morton = aabb_center >-> normalize >-> morton_2D
  let ts = radix_sort_by_key morton u64.num_bits u64.get_bit ts
  let empty_aabb = {min = vec (0, 0), max = vec (0, 0)}
  let empty_aabb {left, right, parent} = {aabb = empty_aabb, left, right, parent}
  let inners = map empty_aabb (mk_radix_tree (map morton ts))
  let depth = i32.f32 (f32.log2 (f32.i64 n)) + 2
  let get_aabb inners ptr =
    match ptr
    case #leaf i -> #[unsafe] ts[i]
    case #inner i -> #[unsafe] inners[i].aabb
  let update inners {aabb = _, left, right, parent} =
    { aabb = surrounding_box (get_aabb inners left) (get_aabb inners right)
    , left
    , right
    , parent
    }
  let inners =
    loop inners for _i < depth do
      map (update inners) inners
  in {L = ts, I = inners}

def bvh_hit [n] (contains: aabb -> bool) (t: bvh [n]) : i32 =
  (.0)
  <| loop (acc, cur, prev) = (0, 0, #inner (-1))
     while cur != -1 do
       let node = #[unsafe] t.I[cur]
       let from_left = prev == node.left
       let from_right = prev == node.right
       let rec_child: #rec ptr | #norec =
         -- Did we return from left node?
         if from_left
         then #rec node.right
         else -- First encounter and in this BB?
         if !from_right && contains node.aabb
         then #rec node.left
         else #norec
       in match rec_child
          case #norec ->
            (acc, node.parent, #inner cur)
          case #rec ptr ->
            match ptr
            case #inner i -> (acc, i, #inner cur)
            case #leaf i ->
              let new_acc = if contains (#[unsafe] t.L[i]) then acc + 1 else acc
              in (new_acc, cur, ptr)
