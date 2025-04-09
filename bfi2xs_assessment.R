# BFI-2-XS Personality Assessment Calculation
# This script calculates personality scores using the Big Five Inventory-2-Extra Short Form (BFI-2-XS)

# --------------------------------
# 1. Setup and Package Installation
# --------------------------------

# Install required packages if not already installed
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(dplyr, car, psych, stargazer, readr)

# --------------------------------
# 2. Configuration Parameters
# --------------------------------
# Define these at the beginning to make the script more configurable
MIN_PROGRESS_THRESHOLD <- 80  # Minimum completion percentage to include a response
LIKERT_SCALE_MAX <- 5         # Maximum value in the Likert scale (typically 5)
OUTPUT_FILENAME <- "data/bfi2xs_results.csv"  # Store results in the data folder

# --------------------------------
# 3. Data Loading and Preprocessing
# --------------------------------

load_bfi_data <- function(numeric_file, categorical_file = NULL, separator = ",") {
  # Check if file path includes "data/" prefix, add it if not
  if (!grepl("^data/", numeric_file)) {
    numeric_file <- file.path("data", numeric_file)
  }
  
  # Load numeric data
  tryCatch({
    bfi_numeric <- read.csv(numeric_file,
                          sep = separator,
                          na.strings = " ", 
                          header = TRUE,
                          check.names = FALSE)
    
    # Filter out incomplete responses if Progress column exists
    if ("Progress" %in% colnames(bfi_numeric)) {
      bfi_numeric <- subset(bfi_numeric, Progress >= MIN_PROGRESS_THRESHOLD)
      message(paste("Filtered numeric data to", nrow(bfi_numeric), "complete responses"))
    } else {
      message("No 'Progress' column found in numeric data. Using all responses.")
    }
    
    # Load categorical data if provided
    if (!is.null(categorical_file)) {
      # Add data/ prefix if missing
      if (!grepl("^data/", categorical_file)) {
        categorical_file <- file.path("data", categorical_file)
      }
      
      bfi_categorical <- read.csv(categorical_file,
                                sep = separator,
                                na.strings = "", 
                                header = TRUE,
                                check.names = FALSE)
      
      # Filter out incomplete responses if Progress column exists
      if ("Progress" %in% colnames(bfi_categorical)) {
        bfi_categorical <- subset(bfi_categorical, Progress >= MIN_PROGRESS_THRESHOLD)
        message(paste("Filtered categorical data to", nrow(bfi_categorical), "complete responses"))
      } else {
        message("No 'Progress' column found in categorical data. Using all responses.")
      }
      
      return(list(numeric = bfi_numeric, categorical = bfi_categorical))
    }
    
    return(list(numeric = bfi_numeric))
  }, error = function(e) {
    stop("Error loading data: ", e$message)
  })
}

# --------------------------------
# 4. Extract BFI Items
# --------------------------------

extract_bfi_items <- function(bfi_data, item_names) {
  # Validate that all required columns exist
  missing_columns <- setdiff(item_names, colnames(bfi_data))
  if (length(missing_columns) > 0) {
    stop("Missing required BFI items: ", paste(missing_columns, collapse = ", "))
  }
  
  # Extract just the BFI items as a data frame
  bfi_items <- bfi_data[, item_names, drop = FALSE]
  
  # Check for missing values
  missing_count <- sum(is.na(bfi_items))
  if (missing_count > 0) {
    warning(paste("Found", missing_count, "missing values in BFI items"))
  }
  
  return(bfi_items)
}

# --------------------------------
# 5. BFI-2-XS Scoring Function
# --------------------------------

# The BFI-2-XS assesses the Big Five personality traits:
# - Agreeableness (A): Being compassionate, respectful, and reflective
# - Conscientiousness (C): Being organized, productive, and responsible
# - Extraversion (E): Being sociable, assertive, and energetic
# - Negative Emotionality/Neuroticism (N): Being prone to anxiety, depression, and emotional volatility
# - Open-Mindedness/Openness (O): Being intellectually curious, appreciative of art, and open to new ideas

score_bfi2xs <- function(bfi_items, spanish_version = TRUE) {
  # Define item indices for each trait dimension based on language version
  if (spanish_version) {
    # Spanish BFI-2-XS trait dimensions (from the SP-BFI-2-XS scoring instructions)
    agreeableness_items <- c(1, 3, 14)  # compasivo, respetuoso, bienpensado
    neuroticism_items <- c(2, 8, 12)    # relajado, estable, melancolico
    conscientiousness_items <- c(4, 9, 11)  # formal, ordenado, tenaz
    openness_items <- c(6, 13, 15)      # arte, abstracto, original
    extraversion_items <- c(5, 7, 10)   # callado, dominante, energizado
    
    # Extract items for each dimension
    agreeableness <- bfi_items[, agreeableness_items, drop = FALSE]
    neuroticism <- bfi_items[, neuroticism_items, drop = FALSE]
    conscientiousness <- bfi_items[, conscientiousness_items, drop = FALSE]
    openness <- bfi_items[, openness_items, drop = FALSE]
    extraversion <- bfi_items[, extraversion_items, drop = FALSE]
    
    # Apply reverse scoring for specific items (Spanish version)
    # Extraversion: Item 5 (callado) is reverse-scored
    extraversion[, 1] <- LIKERT_SCALE_MAX + 1 - extraversion[, 1]
    
    # Neuroticism: Items 1 and 2 (relajado, estable) are reverse-scored
    neuroticism[, 1] <- LIKERT_SCALE_MAX + 1 - neuroticism[, 1]
    neuroticism[, 2] <- LIKERT_SCALE_MAX + 1 - neuroticism[, 2]
    
    # Openness: Item 2 (abstracto) is reverse-scored
    openness[, 2] <- LIKERT_SCALE_MAX + 1 - openness[, 2]
    
  } else {
    # English BFI-2-XS trait dimensions (from the English BFI scoring instructions)
    extraversion_items <- c(1, 6, 11)  # talkative, reserved, energy
    agreeableness_items <- c(2, 7, 12)  # fault, helpful, quarrels
    conscientiousness_items <- c(3, 8, 13)  # thorough, careless, reliable
    neuroticism_items <- c(4, 9, 14)    # depressed, relaxed, tense
    openness_items <- c(5, 10, 15)      # original, curious, ingenious
    
    # Extract items for each dimension
    extraversion <- bfi_items[, extraversion_items, drop = FALSE]
    agreeableness <- bfi_items[, agreeableness_items, drop = FALSE]
    conscientiousness <- bfi_items[, conscientiousness_items, drop = FALSE]
    neuroticism <- bfi_items[, neuroticism_items, drop = FALSE]
    openness <- bfi_items[, openness_items, drop = FALSE]
    
    # Apply reverse scoring for specific items (English version)
    # Extraversion: Item 2 (reserved) is reverse-scored
    extraversion[, 2] <- LIKERT_SCALE_MAX + 1 - extraversion[, 2]
    
    # Agreeableness: Items 1 and 3 (fault, quarrels) are reverse-scored
    agreeableness[, 1] <- LIKERT_SCALE_MAX + 1 - agreeableness[, 1]
    agreeableness[, 3] <- LIKERT_SCALE_MAX + 1 - agreeableness[, 3]
    
    # Conscientiousness: Item 2 (careless) is reverse-scored
    conscientiousness[, 2] <- LIKERT_SCALE_MAX + 1 - conscientiousness[, 2]
    
    # Neuroticism: Item 2 (relaxed) is reverse-scored (lower = more neurotic)
    neuroticism[, 2] <- LIKERT_SCALE_MAX + 1 - neuroticism[, 2]
  }
  
  # Calculate dimension scores by summing items
  agreeableness_score <- rowSums(agreeableness)
  neuroticism_score <- rowSums(neuroticism)
  conscientiousness_score <- rowSums(conscientiousness)
  openness_score <- rowSums(openness)
  extraversion_score <- rowSums(extraversion)
  
  # Combine original items and calculated scores
  results <- cbind(
    bfi_items,
    Agreeableness = agreeableness_score,
    Neuroticism = neuroticism_score,
    Conscientiousness = conscientiousness_score,
    Openness = openness_score,
    Extraversion = extraversion_score
  )
  
  return(results)
}

# --------------------------------
# 6. Correlation Analysis
# --------------------------------

analyze_correlations <- function(bfi_results, plot = TRUE, export_html = FALSE) {
  # Calculate correlation matrix
  cor_matrix <- cor(bfi_results, use = "pairwise.complete.obs")
  
  # Create visualization if requested
  if (plot) {
    pdf("data/bfi2xs_correlations.pdf")
    psych::cor.plot(cor_matrix, main = "BFI-2-XS Item Correlations")
    dev.off()
    message("Correlation plot saved to 'data/bfi2xs_correlations.pdf'")
  }
  
  # Export to HTML if requested
  if (export_html) {
    # Create a copy for display purposes
    display_matrix <- cor_matrix
    display_matrix[upper.tri(display_matrix, diag = TRUE)] <- NA
    
    stargazer(display_matrix, 
              summary = FALSE, 
              type = 'html', 
              initial.zero = FALSE, 
              digits = 2,
              out = "data/bfi2xs_correlations.html")
    
    message("Correlation matrix exported to 'data/bfi2xs_correlations.html'")
  }
  
  return(cor_matrix)
}

# --------------------------------
# 7. Main Execution Function
# --------------------------------

run_bfi2xs_analysis <- function(numeric_file, 
                              categorical_file = NULL,
                              spanish_version = TRUE,
                              export_csv = TRUE,
                              analyze_cors = TRUE) {
  
  # Load data
  data_list <- load_bfi_data(numeric_file, categorical_file)
  bfi_data <- data_list$numeric
  
  # Define item names based on language
  if (spanish_version) {
    # Spanish BFI-2-XS (items 1-15 from the Spanish form)
    item_names <- c("compasivo", "relajado", "respetuoso", "formal", "callado",
                    "arte", "dominante", "estable", "ordenado", "energizado",
                    "tenaz", "melancolico", "abstracto", "bienpensado", "original")
  } else {
    # English BFI-2-XS (first 15 items from the English form)
    item_names <- c("talkative", "fault", "thorough", "depressed", "original",
                    "reserved", "helpful", "careless", "relaxed", "curious",
                    "energy", "quarrels", "reliable", "tense", "ingenious")
  }
  
  # Extract BFI items
  bfi_items <- extract_bfi_items(bfi_data, item_names)
  
  # Score the BFI-2-XS (pass spanish_version parameter to scoring function)
  results <- score_bfi2xs(bfi_items, spanish_version)
  
  # Analyze correlations if requested
  if (analyze_cors) {
    cor_matrix <- analyze_correlations(results, plot = TRUE, export_html = TRUE)
  }
  
  # Export results if requested
  if (export_csv) {
    readr::write_csv(results, OUTPUT_FILENAME)
    message(paste("Results exported to", OUTPUT_FILENAME))
  }
  
  return(results)
}

# --------------------------------
# 8. Example Usage
# --------------------------------

# Uncomment and modify the line below to run the analysis
results <- run_bfi2xs_analysis("example_es.csv")

# Print summary statistics
# summary(results[, c("Agreeableness", "Neuroticism", "Conscientiousness", "Openness", "Extraversion")])