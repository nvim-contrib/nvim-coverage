use std::time::{Duration, Instant};

pub struct Timer {
    duration: Duration,
    start: Option<Instant>,
}

impl Timer {
    pub fn new(seconds: u64) -> Self {
        Timer {
            duration: Duration::from_secs(seconds),
            start: None,
        }
    }

    pub fn start(&mut self) {
        self.start = Some(Instant::now());
    }

    pub fn elapsed(&self) -> Option<Duration> {
        self.start.map(|s| s.elapsed())
    }

    pub fn remaining(&self) -> Option<Duration> {
        self.elapsed().and_then(|e| {
            if e < self.duration {
                Some(self.duration - e)
            } else {
                None
            }
        })
    }

    pub fn is_expired(&self) -> bool {
        self.remaining().is_none()
    }

    pub fn reset(&mut self) {
        self.start = None;
    }
}
