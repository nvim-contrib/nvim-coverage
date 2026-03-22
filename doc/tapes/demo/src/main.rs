mod app;
mod hook;
mod session;
mod timer;

fn main() {
    let config = app::cmd::Config::default();
    let result = app::cmd::run(&config);
    match result {
        Ok(()) => println!("Done"),
        Err(e) => eprintln!("Error: {}", e),
    }
}
