use crate::{assets::Light, components::Camera, ecs::World};
use std::sync::{Arc, Mutex};

pub const MAX_LIGHTS: usize = 255;

pub struct Scene {
    pub world: Arc<World>,
    pub camera: Mutex<Arc<Camera>>,
    pub lights: Mutex<Vec<Arc<Light>>>,
    pub ambient: Mutex<f32>,
}

impl Scene {
    pub fn new(
        world: Arc<World>,
        camera: Arc<Camera>,
        lights: Vec<Arc<Light>>,
        ambient: f32,
    ) -> Arc<Self> {
        Arc::new(Self {
            world,
            camera: Mutex::new(camera),
            lights: Mutex::new(lights),
            ambient: Mutex::new(ambient),
        })
    }
}
