#' Fonction d'import d'un dataset à partir d'un fichier ZIP téléchargeable
#'
#' @param url car url du jeu de données
#' @param name char nom du jeu de données
#' @param format format du fichier téléchargé (zip)
#'
#' @return
#' Aucun
#' @export
#'
#' @examples
#' import_dataset('https://www.data.gouv.fr/fr/datasets/r/98dbe26f-a2e4-4002-a598-c226bf6af664','agritox','zip')
import_dataset <- function(url, name, format){
  
  name <- tolower(make.names(name))
  # URL stable du jeu de données Agritox
  folder <- paste0('data',"/",name)
  file <- paste0('data',"/",name,"/",name,".",format)
  if (!dir.exists(folder)) {dir.create(folder)}
  download.file(url, file, mode='wb')
  # unzip
  if(format == "zip"){
    unzip(zipfile = file, exdir=folder)#%>%
  }
}
