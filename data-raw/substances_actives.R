## code to prepare `substances_actives` dataset goes here

library(dplyr)
library(RefPesticidesBzh)

# Load referentiel table ----

data("referentiels", package="RefPesticidesBzh") 

# Load and format datasets from RefPesticidesBzh package ----

## Load reg-substances-export (ECHA) ----

echa_path <- system.file("echa/reg-substances-export.xlsx", package = "RefPesticidesBzh")
echa <- readxl::read_xlsx(echa_path, skip = 2)
# Remove 'exported.column.' prefix
names(echa) <- make.names(gsub('exported.column.', '', names(echa)))

### Format to substances table ----

colnames <- referentiels %>% filter(dataset == 'echa')

echa_substances <- echa %>%
  # Statut d'autorisation EU : "Active", "Cease Manufacture", "No longer Valid", NA --> "Non autorisé" / ""
  mutate(
    registrationStatus = ifelse(registrationStatus == 'Active', 'autorisé', 'non autorisé'),
    mise_a_jour = as.Date(lastUpdated, '%d-%m-%Y'),
    dataset = "echa",
    source = "ECHA"
  ) %>%
  rename_at(vars(colnames$column_name), ~ colnames$variable) %>%
  select(any_of(c(colnames$variable,'dataset','source','mise_a_jour')))


## Load oeb_referentiels_substances_actives (OEB) ----

oeb_path <- system.file("oeb/", package = "RefPesticidesBzh")
oeb_referentiels_substances_actives <-
  RefPesticidesBzh::load_dataset(path = oeb_path,
                                 pattern = "*.csv",
                                 encoding = "UTF-8")

### Format to substances table ----

colnames <- referentiels %>% filter(dataset == 'oeb')

oeb_substances <-
  oeb_referentiels_substances_actives$oeb_referentiels_substances_actives %>%
  mutate(SA_CodeSANDRE = `X.U.FEFF.SA_CodeSANDRE`,
         SA_Statut = ifelse(SA_Statut == 'non autorisé',SA_Statut,NA),
    mise_a_jour = as.Date(`MaJ`),
         dataset = "oeb") %>%
  rename_at(vars(colnames$column_name), ~ colnames$variable) %>%
  select(any_of(c(colnames$variable,'dataset','source','mise_a_jour')))

## AGRITOX (ANSES) ----

agritox_path <-
  system.file("agritox/", package = "RefPesticidesBzh")
agritox <-
  RefPesticidesBzh::load_dataset(path = agritox_path,
                                 pattern = "*.csv",
                                 encoding = "Latin-1")

agritox$mise_a_jour <-
  RefPesticidesBzh::metadonnees_dataset('https://www.data.gouv.fr/fr/datasets/base-de-donnees-agritox/')$`Modifiée.le` %>% as.Date("%d %b %Y")

### Format to substances table ----

colnames <- referentiels %>% filter(dataset == 'agritox')

agritox_substances <- agritox$agritox_identite %>%
  left_join(
    select(agritox$agritox_ecotoxicite, Numéro.CAS, Valeur.PNEC),
    by = c("N..CAS" = "Numéro.CAS")
  ) %>%
  tibble::as_tibble() %>%
  mutate(
    `Valeur.PNEC` = as.numeric(`Valeur.PNEC`),
    source = "AGRITOX",
    dataset = "agritox",
    mise_a_jour = agritox$mise_a_jour
  ) %>%
  rename_at(vars(colnames$column_name), ~ colnames$variable) %>%
  select(any_of(c(colnames$variable,'dataset','source','mise_a_jour')))

## Load ephy (ANSES) ----

ephy_path <- system.file("ephy/", package = "RefPesticidesBzh")
ephy <-
  RefPesticidesBzh::load_dataset(path = ephy_path,
                                 pattern = "*.csv",
                                 encoding = "UTF-8")

ephy$mise_a_jour <-
  RefPesticidesBzh::metadonnees_dataset(
    'https://www.data.gouv.fr/fr/datasets/donnees-ouvertes-du-catalogue-e-phy-des-produits-phytopharmaceutiques-matieres-fertilisantes-et-supports-de-culture-adjuvants-produits-mixtes-et-melanges/'
  )$`Modifiée.le` %>% 
  as.Date("%d %b %Y")

### Format to substances table ----

colnames <- referentiels %>% filter(dataset == 'ephy')

ephy_substances <- ephy$substance_active_v3_utf8 %>%
  tibble::as_tibble() %>%
  # Etat d'autorisation : "NON_INSCRITE" "INSCRIPTION_EN_COURS" "INSCRITE" "AUTRE_CAS"
  mutate(
    Etat.d.autorisation = case_when(
      Etat.d.autorisation == 'INSCRIPTION_EN_COURS' ~ 'non autorisé',
      Etat.d.autorisation == 'NON_INSCRITE' ~ 'non autorisé',
      Etat.d.autorisation == 'INSCRITE' ~ 'autorisé'
    ),
    source = "Données E-Phy - Anses",
    dataset = "ephy",
    mise_a_jour = ephy$mise_a_jour
  ) %>%
  rename_at(vars(colnames$column_name), ~ colnames$variable) %>%
  select(any_of(c(colnames$variable,'dataset','source','mise_a_jour')))

## Load SIRIS (INERIS) ----

siris_path <-
  system.file("siris/siris.xls", package = "RefPesticidesBzh")
siris <- readxl::read_xls(siris_path, skip = 5)
names(siris) <- make.names(names(siris))
siris$mise_a_jour <- as.Date('2012-06-30')

### Format to substances table ----

colnames <- referentiels %>% filter(dataset == 'siris')

siris_substances <- siris %>%
  tibble::as_tibble() %>%
  mutate(source = "SIRIS Pesticides - INERIS",
    dataset = "siris",
    mise_a_jour = siris$mise_a_jour
    ) %>%
  rename_at(vars(colnames$column_name), ~ colnames$variable) %>%
  select(any_of(c(colnames$variable,'dataset','source','mise_a_jour')))

# Bind substances tables ----

substances_actives_union <- agritox_substances %>%
  dplyr::bind_rows(ephy_substances) %>%
  dplyr::bind_rows(oeb_substances) %>%
  dplyr::bind_rows(echa_substances) %>%
  dplyr::bind_rows(siris_substances)%>%
  arrange(SA_CodeCAS)

# Comparaison table of variables differences beetween datasets ----

substances_actives_comparaison <- substances_actives_union %>%
  filter(!is.na(SA_CodeCAS)) %>%
  group_by(SA_CodeCAS) %>%
  # Le Libelle n'est pas retenu comme ambiguïté
  mutate(SA_Libelle = first(SA_Libelle)) %>%
  # Table longue des attributs
  tidyr::pivot_longer(!c("dataset","SA_CodeCAS","SA_Libelle","source","mise_a_jour"), 
                      values_transform = list(value = as.character), values_drop_na = TRUE) %>%
  select(SA_CodeCAS, SA_Libelle, name, value, dataset) %>%
  group_by(SA_CodeCAS, SA_Libelle, name) %>%
  # Au moins 2 valeurs distinctes (non nulles) par CodeCAS et attribut
  filter(n_distinct(value, na.rm = TRUE)>1) %>%
  # Au moins deux sources de données différentes
  filter(n_distinct(dataset, na.rm = TRUE)>1) %>%
  # Table large par dataset
  tidyr::pivot_wider(names_from = dataset, values_from = value, values_fill = NA)

# Alternative
#
# substances_actives_comparaison <- substances_actives_union %>%
#   group_by(SA_CodeCAS) %>%
#   mutate(SA_Libelle = first(SA_Libelle)) %>%
#   filter(if_any(.cols = !c("source", "mise_a_jour","dataset"), ~ n_distinct(.x, na.rm = TRUE)>1 ))

# Format final table ----

referentiels_parvariable <- referentiels %>%
  tidyr::pivot_wider(names_from = variable, values_from = rank)

substances_actives <- substances_actives_union %>%
  left_join(referentiels_parvariable,
            by = "dataset",
            suffix = c("", ".rank")) %>%
  # Compare datasets by SA_CodeCAS
  group_by(SA_CodeCAS) %>%
  # Retain first dataset by hierarchy rank for each variable
  summarise(
    SA_CodeSANDRE = first(SA_CodeSANDRE, order_by = SA_CodeSANDRE.rank),
    SA_Libelle = first(SA_Libelle, order_by = SA_Libelle.rank),
    SA_Statut = first(SA_Statut, order_by = SA_Statut.rank),
    SA_PNEC = first(SA_PNEC, order_by = SA_PNEC.rank),
    SA_Usage_principal = first(SA_Usage_principal, order_by = SA_Usage_principal.rank),
    SA_Koc = first(SA_Koc, order_by = SA_Koc.rank),
    SA_DT50 = first(SA_DT50, order_by = SA_DT50.rank),
    SA_HydrolysePH7 = first(SA_HydrolysePH7, order_by = SA_HydrolysePH7.rank),
    SA_Solubilite_mgl = first(SA_Solubilite_mgl, order_by = SA_Solubilite_mgl.rank),
    mise_a_jour = max(mise_a_jour)
  )

# Export .rda dataset to data/

usethis::use_data(substances_actives, overwrite = TRUE)
