#[derive(Default, Copy, Clone)]
pub struct Vertex {
    pub position: [f32; 3],
}

vulkano::impl_vertex!(Vertex, position);