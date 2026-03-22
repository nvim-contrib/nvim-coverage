#[derive(Debug)]
pub enum Event {
    Start,
    Stop,
    Pause,
    Resume,
}

pub struct Hook {
    pub name: String,
    pub enabled: bool,
}

impl Hook {
    pub fn new(name: impl Into<String>) -> Self {
        Hook {
            name: name.into(),
            enabled: true,
        }
    }

    pub fn run(&self, event: &Event) -> bool {
        if !self.enabled {
            return false;
        }

        match event {
            Event::Start => {
                println!("Hook '{}' triggered: start", self.name);
                true
            }
            Event::Stop => {
                println!("Hook '{}' triggered: stop", self.name);
                true
            }
            Event::Pause => false,
            Event::Resume => false,
        }
    }
}

pub fn run_all(hooks: &[Hook], event: &Event) -> usize {
    hooks.iter().filter(|h| h.run(event)).count()
}
