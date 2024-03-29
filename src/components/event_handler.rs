use crate::ecs::{self, reexports::*};
use winit::event::Event;

pub const EVENT_HANDLER_ID: &str = "event handler";

pub trait Handler: Send + Sync {
    fn set_event_handler(&self, _: Option<Arc<EventHandler>>) {}

    fn handle<'a>(&self, event: &Event<'a, ()>);
}

#[derive(Component)]
pub struct EventHandler {
    pub id: Arc<String>,
    pub tid: Arc<String>,
    pub entity: Arc<RwLock<Option<Arc<Entity>>>>,
    pub handler: Arc<RwLock<Arc<dyn Handler>>>,
}

impl EventHandler {
    pub fn new(id: Arc<String>, handler: Arc<dyn Handler>) -> Arc<Self> {
        let event_handler = Arc::new(Self {
            id,
            tid: ecs::id(EVENT_HANDLER_ID),
            entity: ecs::entity(None),
            handler: Arc::new(RwLock::new(handler.clone())),
        });

        handler.set_event_handler(Some(event_handler.clone()));

        event_handler
    }

    pub fn handle<'a>(&self, event: &Event<'a, ()>) {
        self.handler.read().unwrap().handle(event);
    }
}
