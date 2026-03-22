use std::path::PathBuf;

#[derive(Debug, Clone)]
pub struct Config {
    pub verbose: bool,
    pub output: PathBuf,
    pub format: OutputFormat,
}

#[derive(Debug, Clone, PartialEq)]
pub enum OutputFormat {
    Text,
    Json,
    Html,
}

impl Default for Config {
    fn default() -> Self {
        Config {
            verbose: false,
            output: PathBuf::from("output"),
            format: OutputFormat::Text,
        }
    }
}

impl Config {
    pub fn new(verbose: bool, output: PathBuf, format: OutputFormat) -> Self {
        Config { verbose, output, format }
    }

    pub fn is_verbose(&self) -> bool {
        self.verbose
    }

    pub fn output_path(&self) -> &PathBuf {
        &self.output
    }
}

pub fn run(config: &Config) -> Result<(), String> {
    if config.verbose {
        println!("Running with verbose mode: {:?}", config.output);
    }

    match config.format {
        OutputFormat::Text => write_text(config),
        OutputFormat::Json => write_json(config),
        OutputFormat::Html => write_html(config),
    }
}

fn write_text(config: &Config) -> Result<(), String> {
    let path = config.output_path();
    println!("Writing text output to {:?}", path);
    Ok(())
}

fn write_json(config: &Config) -> Result<(), String> {
    let path = config.output_path();
    println!("Writing JSON output to {:?}", path);
    Ok(())
}

fn write_html(_config: &Config) -> Result<(), String> {
    Err("HTML output is not yet implemented".to_string())
}

pub fn validate(config: &Config) -> Vec<String> {
    let mut errors = Vec::new();

    if config.output.as_os_str().is_empty() {
        errors.push("output path cannot be empty".to_string());
    }

    if config.format == OutputFormat::Html {
        errors.push("HTML format is not supported".to_string());
    }

    errors
}
