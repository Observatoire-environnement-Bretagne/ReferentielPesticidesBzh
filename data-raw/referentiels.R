# Set dataset hierarchy for each variable ----

library(dplyr)

referentiels <- dplyr::bind_rows(
  # Code CAS ----
    data.frame(dataset = c('echa', 'ephy','siris', 'oeb'), 
               column_name = c('casNumber','Numero.CAS','CAS.SIRIS.2012','SA_CodeCAS')) %>% 
      mutate(variable = 'SA_CodeCAS', rank = 1:n()),
  # Code SANDRE ----
  data.frame(dataset = c('sandre', 'siris','oeb'), 
             column_name = c('CdParametre','Code.Sandre','SA_CodeSANDRE')
             ) %>% 
    mutate(variable = 'SA_CodeSANDRE', rank = 1:n()),
  # Libelle ----
  data.frame(dataset = c('ephy', 'sandre','echa','oeb'), 
             column_name = c('Nom.substance.active','LbParametre','name','SA_Libelle')
             ) %>% 
    mutate(variable = 'SA_Libelle', rank = 1:n()),
  # Statut d'autorisation EU
  data.frame(dataset = c('echa', 'ephy','oeb'), 
             column_name = c('registrationStatus','Etat.d.autorisation','SA_Statut')
  ) %>% 
    mutate(variable = 'SA_Statut', rank = 1:n()),
  # PNEC ----
  data.frame(dataset = c('agritox','oeb'), 
             column_name = c('Valeur.PNEC','SA_PNEC')
  ) %>% 
    mutate(variable = 'SA_PNEC', rank = 1:n()),
  # Usage Principal ----
  data.frame(dataset = c('siris','oeb'), 
             column_name = c('Activité.biologique','SA_Usage_principal')
  ) %>% 
    mutate(variable = 'SA_Usage_principal', rank = 1:n()),
  # SA_Koc ----
  data.frame(dataset = c('siris','oeb'), 
             column_name = c('Koc..mL.g.1.','SA_Koc')
  ) %>% 
    mutate(variable = 'SA_Koc', rank = 1:n()),
  # DT50 ----
  data.frame(dataset = c('siris','oeb'), 
             column_name = c('DT50.champ..jours.','SA_DT50')
  ) %>% 
    mutate(variable = 'SA_DT50', rank = 1:n()),
  # Hydrolyse pH7 ----
  data.frame(dataset = c('siris','oeb'), 
             column_name = c('Hydrolyse.à.pH.7','SA_HydrolysePH7')
  ) %>% 
    mutate(variable = 'SA_HydrolysePH7', rank = 1:n()),
  # Solubilité ----
  data.frame(dataset = c('siris','oeb'), 
             column_name = c('Solub..mg.L.1.','SA_Solubilite_mgl')
  ) %>% 
    mutate(variable = 'SA_Solubilite_mgl', rank = 1:n())
)


# Export .rda to data/

usethis::use_data(referentiels, overwrite = TRUE)
