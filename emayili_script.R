library(emayili)

# Always print envelope details.
options(
  envelope.details = TRUE,
  envelope.invisible = FALSE
)

packageVersion("emayili")
# create envelope object --------------------------------------------------

email <- envelope()


# Add addresses for the sender and recipient ------------------------------

email <- email |>
  from("andrewbruce.himni@gmail.com") |>
  to("andrewbruce.himni@gmail.com") |>
  cc("andybruce07@gmail.com")


# Add a subject -----------------------------------------------------------

email <- email |> subject("Emayili Markdown Report 2")


# Add a text body ---------------------------------------------------------

email <- email |> text("Emayili Markdown Report 2")



# Rendering Markdown ------------------------------------------------------

email <- envelope() |>
  from("andrewbruce.himni@gmail.com") |>
  to("andrewbruce.himni@gmail.com") |>
  cc("andybrucemusic@gmail.com") |>
  subject("Emayili Markdown Report 2") |>
  text("Emayili Markdown Report 2") |>
  render("email_test.Rmd")


############ FINAL STEP ---------------------------------------------------
# Create a server object --------------------------------------------------

smtp <- server(
  host = "smtp.gmail.com",
  port = 465,
  username = Sys.getenv("GMAIL_USERNAME"),
  password = Sys.getenv("GMAIL_PASSWORD")
)


# Send the message --------------------------------------------------------

smtp(email, verbose = TRUE)
