use crate::timer::Timer;

#[derive(Debug, PartialEq)]
pub enum State {
    Idle,
    Running,
    Paused,
    Done,
}

pub struct Session {
    pub name: String,
    pub state: State,
    timer: Timer,
}

impl Session {
    pub fn new(name: impl Into<String>, duration_secs: u64) -> Self {
        Session {
            name: name.into(),
            state: State::Idle,
            timer: Timer::new(duration_secs),
        }
    }

    pub fn start(&mut self) {
        if self.state == State::Idle {
            self.state = State::Running;
            self.timer.start();
        }
    }

    pub fn pause(&mut self) {
        if self.state == State::Running {
            self.state = State::Paused;
        }
    }

    pub fn resume(&mut self) {
        if self.state == State::Paused {
            self.state = State::Running;
        }
    }

    pub fn finish(&mut self) {
        self.state = State::Done;
        self.timer.reset();
    }

    pub fn is_active(&self) -> bool {
        self.state == State::Running || self.state == State::Paused
    }
}
