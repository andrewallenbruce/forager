# ```{mermaid}
# %%| label: tx-mermaid
# %%| fig-cap: "Example of Taxonomy Hierarchy"
# %%| echo: false
#
# flowchart TB
# A(((Date of Service))) == Provider Signs Chart ==> B(Date of Release)
# B(Date of Release) == Biller Submits Claim ==> C([Date of Submission])
# C([Date of Submission]) == Payer Acknowledges Receipt of Claim ==> D[[Date of Acceptance]]
# E([Date of Submission]) --> L>Addiction Medicine]
# L>Addiction Medicine] --o M[[207LA0401X]]
# ```
