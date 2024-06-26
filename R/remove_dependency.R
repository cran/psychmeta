.consolidate_dependent_u <- function(ux, rxx, n, ux_observed, rxx_restricted){
     if(any(ux_observed) & any(!ux_observed)){
          ux_i <- suppressWarnings(estimate_ux(ut = ux[!ux_observed],
                                               rxx = rxx[!ux_observed],
                                               rxx_restricted = rxx_restricted[!ux_observed]))
          if(any(is.na(ux_i))){
               ux_i_rxxi <- ux_i_rxxa <- ux_i[is.na(ux_i)]
               ux_i_rxxi <- suppressWarnings(estimate_ux(ut = ux[!ux_observed][is.na(ux_i)],
                                                         rxx = wt_mean(x = rxx[!ux_observed & rxx_restricted],
                                                                       wt = n[!ux_observed & rxx_restricted]),
                                                         rxx_restricted = TRUE))

               ux_i_rxxa <- suppressWarnings(estimate_ux(ut = ux[!ux_observed][is.na(ux_i)],
                                                         rxx = wt_mean(x = rxx[!ux_observed & !rxx_restricted],
                                                                       wt = n[!ux_observed & !rxx_restricted]),
                                                         rxx_restricted = FALSE))

               ux_i[is.na(ux_i)][!is.na(ux_i_rxxi) & is.na(ux_i_rxxa)] <- ux_i_rxxi[!is.na(ux_i_rxxi) & is.na(ux_i_rxxa)]
               ux_i[is.na(ux_i)][is.na(ux_i_rxxi) & !is.na(ux_i_rxxa)] <- ux_i_rxxa[is.na(ux_i_rxxi) & !is.na(ux_i_rxxa)]
               ux_i[is.na(ux_i)][!is.na(ux_i_rxxi) & !is.na(ux_i_rxxa)] <- (ux_i_rxxi[!is.na(ux_i_rxxi) & !is.na(ux_i_rxxa)] + ux_i_rxxa[!is.na(ux_i_rxxi) & !is.na(ux_i_rxxa)]) / 2
          }
          ux[!ux_observed] <- ux_i
          ux_observed[!ux_observed] <- TRUE
          ux_observed_comp <- TRUE
     }else{
          ux_observed_comp <- ux_observed[1]
     }
     list(ux = ux, ux_observed = ux_observed, ux_observed_comp = ux_observed_comp)
}



.colsolidate_dependent_rel <- function(rxx, ryy, ux, uy, n, n_adj, rxyi = NULL,
                                       rxx_restricted, ryy_restricted,
                                       ux_observed, uy_observed, 
                                       indirect_rr_x = TRUE, indirect_rr_y = TRUE,
                                       rxx_type = "alpha", ryy_type = "alpha"){
  if(length(indirect_rr_x) == 1) indirect_rr_x <- rep(indirect_rr_x, length(rxx))
  if(length(indirect_rr_y) == 1) indirect_rr_y <- rep(indirect_rr_y, length(rxx))
  if(length(rxx_type) == 1) rxx_type <- rep(rxx_type, length(rxx))
  if(length(ryy_type) == 1) ryy_type <- rep(ryy_type, length(rxx))
  
  if(any(!rxx_restricted)){
    if(!is.null(ux)){
      ux_i <- ux
      if(any(!is.na(ux_i))){
        if(any(is.na(ux_i[!rxx_restricted]))){
          ux_i[is.na(ux_i)] <- wt_mean(x = ux_i[!is.na(ux_i)], wt = n[!is.na(ux_i)])
        }
        rxxi_i <- estimate_rxxi(rxxa = rxx[!rxx_restricted],
                                ux = ux_i[!rxx_restricted],
                                ux_observed = ux_observed[!rxx_restricted],
                                indirect_rr = indirect_rr_x[!rxx_restricted])
        rxx[!rxx_restricted][!is.na(rxxi_i)] <- rxxi_i[!is.na(rxxi_i)]
        rxx_restricted[!rxx_restricted][!is.na(rxxi_i)] <- TRUE
      }else{
        if(!is.null(uy)){
          uy_i <- uy
          if(any(!is.na(uy_i))){
            if(any(is.na(uy_i[!rxx_restricted]))){
              uy_i[is.na(uy_i)] <- wt_mean(x = uy_i[!is.na(uy_i)], wt = n[!is.na(uy_i)])
            }
            rxxi_i <- estimate_ryyi(ryya = rxx[!rxx_restricted],
                                    rxyi = rep(wt_mean(x = rxyi, wt = n_adj), sum(!rxx_restricted)),
                                    ux = uy_i[!rxx_restricted],
                                    rxx_restricted = ryy_restricted[!rxx_restricted],
                                    ux_observed = ux_observed[!rxx_restricted],
                                    indirect_rr = indirect_rr_y[!rxx_restricted],
                                    rxx_type = rxx_type[!rxx_restricted])
            rxx[!rxx_restricted][!is.na(rxxi_i)] <- rxxi_i[!is.na(rxxi_i)]
            rxx_restricted[!rxx_restricted][!is.na(rxxi_i)] <- TRUE
          }
        }
      }
      rxx[!rxx_restricted] <- NA
      rxx_restricted[!rxx_restricted] <- TRUE
      rxx_restricted_comp <- TRUE
    }
  }else{
    rxx_restricted_comp <- rxx_restricted[1]
  }
  list(rxx = rxx, rxx_restricted = rxx_restricted, rxx_restricted_comp = rxx_restricted_comp)
}

.consolidate_dependent_artifacts <- function(n, n_adj, p = rep(.5, length(es)), es, es_metric,
                                             rxx, ryy, ux, uy, 
                                             rxx_restricted, ryy_restricted, 
                                             ux_observed, uy_observed,
                                             indirect_rr_x = TRUE, indirect_rr_y = TRUE,
                                             rxx_type = "alpha", ryy_type = "alpha"){
     ux_out <- .consolidate_dependent_u(ux = ux,
                                        rxx = rxx,
                                        n = n, 
                                        ux_observed = ux_observed,
                                        rxx_restricted = rxx_restricted)
     uy_out <- .consolidate_dependent_u(ux = uy,
                                        rxx = ryy,
                                        n = n, 
                                        ux_observed = uy_observed,
                                        rxx_restricted = ryy_restricted)

     if(es_metric == "d") es <- convert_es.q_d_to_r(d = es, p = p)

     rxx_out <- .colsolidate_dependent_rel(rxx = rxx,
                                           ryy = ryy,
                                           ux = ux_out$ux,
                                           uy = uy_out$ux,
                                           n = n,
                                           n_adj = n_adj,
                                           rxyi = es, 
                                           rxx_restricted = rxx_restricted,
                                           ryy_restricted = ryy_restricted,
                                           ux_observed = ux_out$ux_observed,
                                           uy_observed = uy_out$ux_observed,
                                           indirect_rr_x = indirect_rr_x,
                                           indirect_rr_y = indirect_rr_y,
                                           rxx_type = rxx_type,
                                           ryy_type = ryy_type)
     ryy_out <- .colsolidate_dependent_rel(rxx = ryy,
                                           ryy = rxx,
                                           ux = uy_out$ux,
                                           uy = ux_out$ux,
                                           n = n,
                                           n_adj = n_adj,
                                           rxyi = es, 
                                           rxx_restricted = ryy_restricted,
                                           ryy_restricted = rxx_restricted,
                                           ux_observed = uy_out$ux_observed,
                                           uy_observed = ux_out$ux_observed,
                                           indirect_rr_x = indirect_rr_y,
                                           indirect_rr_y = indirect_rr_x,
                                           rxx_type = ryy_type,
                                           ryy_type = rxx_type)

     list(ux = ux_out,
          uy = uy_out,
          rxx = rxx_out,
          ryy = ryy_out)
}

.remove_dependency <- function(sample_id = NULL, citekey = NULL, es_data = NULL, data_x = NULL, data_y = NULL,
                               collapse_method = c("stop", "composite", "average"), retain_original = TRUE,
                               intercor = .5, partial_intercor = FALSE,
                               construct_x = NULL, construct_y = NULL,
                               measure_x = NULL, measure_y = NULL, moderator_names = NULL,
                               data=NULL, es_metric=c("r", "d"), ma_method, ...) {

     if(!is.null(data)) {
          es_data <- data[,es_data]
          sample_id <- data[,sample_id]
          if(citekey %in% colnames(data)){
               citekey <- data[,citekey]
          }else{
               citekey <- NULL
          }
          data_x <- data[,data_x]
          data_y <- data[,data_y]
          construct_x <- as.character(data[,construct_x])
          construct_y <- as.character(data[,construct_y])
          if(any(colnames(data) == "measure_x")){
               measure_x <- data[,measure_x]
          }else{
               measure_x <- NULL
          }
          if(any(colnames(data) == "measure_y")){
               measure_y <- data[,measure_y]
          }else{
               measure_y <- NULL
          }

          if(length(moderator_names$all) > 0){
               moderators <- as.data.frame(as_tibble(data, .name_repair = "minimal")[,moderator_names$all], stringsAsFactors = FALSE)
          }else{
               moderators <- NULL
          }

     }

     additional_args <- list(...)

     es_metric <- match.arg(es_metric, c("r", "d"))

     dup_IDs <- duplicated(sample_id) | duplicated(sample_id,fromLast=TRUE)
     sample_id_construct_pair <- paste0("ID = ", sample_id, ", X = ", construct_x, ", Y = ", construct_y)

     collapse_es <- any(as.logical(as.numeric(table(sample_id_construct_pair)) > 1))


     collapse_method <- match.arg(collapse_method, c("stop", "composite", "average"))
     if (collapse_method == "stop" & collapse_es) {
       if (nrow(es_data[dup_IDs,]) > 0) {
         stop("\nDuplicate effect sizes found:\n",
              paste(unique(sample_id_construct_pair[dup_IDs]), collapse = "\n"),
              call. = FALSE)
       }
     }

     if(is.null(es_data$pi)) es_data$pi <- rep(.5, nrow(es_data))

     out <- by(1:length(sample_id_construct_pair),
               sample_id_construct_pair,
               .remove_dependency_by_sample_id_construct_pair,
               .data = list(sample_id = sample_id,
                            construct_x = construct_x,
                            construct_y = construct_y,
                            ma_method = ma_method,
                            es_metric = es_metric,
                            collapse_method = collapse_method,
                            intercor = intercor,
                            partial_intercor = partial_intercor,
                            es_data = es_data,
                            data_x = data_x,
                            data_y = data_y,
                            measure_x = measure_x,
                            measure_y = measure_y,
                            moderators = moderators,
                            moderator_names = moderator_names,
                            citekey = citekey,
                            additional_args = additional_args)
     )

     if (!is.null(moderators)) {
          mod_out <- do.call(rbind, lapply(out, function(x) x$moderators_comp))
     } else {
          mod_out <- NULL
     }

     es_data_list <- list(construct_x = unlist(lapply(out, function(x) x$construct_x)),
                          construct_y = unlist(lapply(out, function(x) x$construct_y)),
                          sample_id = unlist(lapply(out, function(x) x$sample_id)),
                          citekey = unlist(lapply(out, function(x) x$citekey)),
                          es = unlist(lapply(out, function(x) x$es_comp)),
                          n = unlist(lapply(out, function(x) x$n_comp)),
                          n_adj = unlist(lapply(out, function(x) x$n_adj_comp)),
                          d = unlist(lapply(out, function(x) x$d_comp)),
                          n1 = unlist(lapply(out, function(x) x$n1_comp)),
                          n2 = unlist(lapply(out, function(x) x$n2_comp)),
                          pi = unlist(lapply(out, function(x) x$pi_comp)),
                          pa = unlist(lapply(out, function(x) x$pa_comp)))

     data_x_list <- list(rxx = unlist(lapply(out, function(x) x$rxx_comp)),
                         rxx_type = unlist(lapply(out, function(x) x$rxx_type)),
                         rxx_consistency = unlist(lapply(out, function(x) x$rxx_consistency)),
                         k_items_x = unlist(lapply(out, function(x) x$k_items_x_comp)),

                         ux = unlist(lapply(out, function(x) x$ux_comp)),
                         rxx_restricted = unlist(lapply(out, function(x) x$rxx_restricted_comp)),
                         ux_observed = unlist(lapply(out, function(x) x$ux_observed_comp)),

                         correct_rr_x = unlist(lapply(out, function(x) x$correct_rr_x)),
                         indirect_rr_x = unlist(lapply(out, function(x) x$indirect_rr_x)),

                         correct_rxx = unlist(lapply(out, function(x) x$correct_rxx)),
                         sign_rxz = unlist(lapply(out, function(x) x$sign_rxz)))

     data_y_list <- list(ryy = unlist(lapply(out, function(x) x$ryy_comp)),
                         ryy_type = unlist(lapply(out, function(x) x$ryy_type)),
                         ryy_consistency = unlist(lapply(out, function(x) x$ryy_consistency)),
                         k_items_y = unlist(lapply(out, function(x) x$k_items_y_comp)),

                         uy = unlist(lapply(out, function(x) x$uy_comp)),
                         ryy_restricted = unlist(lapply(out, function(x) x$ryy_restricted_comp)),
                         uy_observed = unlist(lapply(out, function(x) x$uy_observed_comp)),

                         correct_rr_y = unlist(lapply(out, function(x) x$correct_rr_y)),
                         indirect_rr_y = unlist(lapply(out, function(x) x$indirect_rr_y)),

                         correct_ryy = unlist(lapply(out, function(x) x$correct_ryy)),
                         sign_ryz = unlist(lapply(out, function(x) x$sign_ryz)))

     for(i in names(es_data_list)) if(is.null(es_data_list[[i]])) es_data_list[[i]] <- NULL
     for(i in names(data_x_list)) if(is.null(data_x_list[[i]])) data_x_list[[i]] <- NULL
     for(i in names(data_y_list)) if(is.null(data_y_list[[i]])) data_y_list[[i]] <- NULL

     es_data <- as.data.frame(es_data_list, stringsAsFactors = FALSE)
     if(!is.null(mod_out)) es_data <- cbind(es_data, mod_out)
     data_x <- as.data.frame(data_x_list, stringsAsFactors = FALSE)
     data_y <- as.data.frame(data_y_list, stringsAsFactors = FALSE)

     rownames(es_data) <- 1:nrow(es_data)

     if(nrow(data_x) == 0){
          data_x <- NULL
     }else{
          rownames(data_x) <- 1:nrow(es_data)
          es_data <- data.frame(es_data, data_x, stringsAsFactors = FALSE, check.names = FALSE)
     }
     if(nrow(data_y) == 0){
          data_y <- NULL
     }else{
          rownames(data_y) <- 1:nrow(es_data)
          es_data <- data.frame(es_data, data_y, stringsAsFactors = FALSE, check.names = FALSE)
     }

     es_data
}


.reconcile_artifacts <- function(logic_vec_x = TRUE, logic_vec_y = TRUE, sample_id,
                                 art_vec_x, art_vec_y,
                                 construct_x = NULL, construct_y = NULL,
                                 measure_x = NULL, measure_y = NULL){

     index_x <- 1:sum(logic_vec_x)
     index_y <- (sum(logic_vec_x) + 1):(sum(logic_vec_x) + sum(logic_vec_y))

     sample_id_all <- c(sample_id[logic_vec_x], sample_id[logic_vec_y])
     construct_all <- c(construct_x[logic_vec_x], construct_y[logic_vec_y])
     measure_all <- c(measure_x[logic_vec_x], measure_y[logic_vec_y])
     art_vec_all <- c(art_vec_x[logic_vec_x], art_vec_y[logic_vec_y])

     id_vec <- paste(sample_id_all, construct_all, measure_all)
     lvls <- levels(factor(id_vec))

     art_vec_new <- art_vec_all
     for(i in lvls){
          subset <- id_vec == i
          if(is.logical(art_vec_all)){
               if(sum(subset) > 1 & !all(is.na(art_vec_all[subset]))) art_vec_new[subset] <-  as.logical(round(mean(art_vec_all[subset], na.rm = TRUE)))
          }else{
               if(sum(subset) > 1 & !all(is.na(art_vec_all[subset]))) art_vec_new[subset] <-  mean(art_vec_all[subset], na.rm = TRUE)
          }
     }

     art_vec_x[logic_vec_x] <- art_vec_new[index_x]
     art_vec_y[logic_vec_y] <- art_vec_new[index_y]

     list(art_vec_x = art_vec_x, art_vec_y = art_vec_y)
}

.remove_dependency_by_sample_id_construct_pair <- function(i, .data) {
  if(!is.null(.data$citekey)){
    citekey_comp <- paste(unique(as.character(.data$citekey)[i]), collapse = ",")
  }else{
    citekey_comp <- NULL
  }

  if(!is.null(.data$moderators)){
    moderators <- as.data.frame(.data$moderators)
    moderators_comp_i <- moderators[i,, drop = FALSE]
    moderators_comp <- moderators[1,, drop = FALSE]

    if(!is.null(.data$moderator_names$cat))
      moderators_comp[,.data$moderator_names$cat] <-
        apply(as.data.frame(moderators_comp_i[,.data$moderator_names$cat, drop = FALSE], stringsAsFactors = FALSE),
              2,
              function(x) {paste(sort(unique(as.character(x))), collapse = " & ")}
              )

    if(!is.null(.data$moderator_names$noncat))
      moderators_comp[,.data$moderator_names$noncat] <-
      apply(as.data.frame(moderators_comp_i[,.data$moderator_names$noncat, drop = FALSE], stringsAsFactors = FALSE),
            2,
            function(x){mean(x, na.rm = TRUE)}
            )

    moderators_comp <- as.data.frame(moderators_comp, stringsAsFactors = FALSE)
  } else {
    moderators_comp <- NULL
  }

  if (.data$ma_method != "bb") {
    art_out <- .consolidate_dependent_artifacts(n = .data$es_data$n[i],
                                                n_adj = .data$es_data$n_adj[i],
                                                p = .data$es_data$pi[i],
                                                es = .data$es_data$rxyi[i],
                                                es_metric = .data$es_metric,
                                                rxx = .data$data_x$rxx[i],
                                                ryy = .data$data_y$ryy[i],
                                                ux = .data$data_x$ux[i],
                                                uy = .data$data_y$uy[i],
                                                rxx_restricted = .data$data_x$rxx_restricted[i],
                                                ryy_restricted = .data$data_y$ryy_restricted[i],
                                                ux_observed = .data$data_x$ux_observed[i],
                                                uy_observed = .data$data_y$uy_observed[i],
                                                indirect_rr_x = .data$data_x$indirect_rr_x[i],
                                                indirect_rr_y = .data$data_y$indirect_rr_y[i],
                                                rxx_type = .data$data_x$rxx_type[i],
                                                ryy_type = .data$data_y$ryy_type[i])

    .data$data_x$ux[i] <- art_out$ux$ux
    .data$data_x$ux_observed[i] <- art_out$ux$ux_observed

    .data$data_y$uy[i] <- art_out$uy$ux
    .data$data_y$uy_observed[i] <- art_out$uy$ux_observed

    .data$data_x$rxx[i] <- art_out$rxx$rxx
    .data$data_x$rxx_restricted[i] <- art_out$rxx$rxx_restricted

    .data$data_y$ryy[i] <- art_out$ryy$rxx
    .data$data_y$ryy_restricted[i] <- art_out$ryy$rxx_restricted

    ux_observed_comp <- art_out$ux$ux_observed_comp
    uy_observed_comp <- art_out$uy$ux_observed_comp
    rxx_restricted_comp <- art_out$rxx$rxx_restricted_comp
    ryy_restricted_comp <- art_out$ryy$rxx_restricted_comp

    correct_rr_x <- .data$data_x$correct_rr_x
    correct_rr_y <- .data$data_y$correct_rr_y

    indirect_rr_x <- .data$data_x$indirect_rr_x
    indirect_rr_y <- .data$data_y$indirect_rr_y
  }

  if (.data$collapse_method == "average") {
    if (.data$es_metric == "r") {
      es_comp <- wt_mean(x = .data$es_data$rxyi[i], wt = .data$es_data$n_adj[i])
    } else {
      es_comp <- wt_mean(x = .data$es_data$dxyi[i], wt = .data$es_data$n_adj[i])
    }

    if (.data$ma_method != "bb") {
      rxx_comp <- wt_mean(x = .data$data_x$rxx[i], wt = .data$es_data$n[i])
      ux_comp  <- wt_mean(x = .data$data_x$ux[i],  wt = .data$es_data$n[i])
      ryy_comp <- wt_mean(x = .data$data_y$ryy[i], wt = .data$es_data$n[i])
      uy_comp  <- wt_mean(x = .data$data_y$uy[i],  wt = .data$es_data$n[i])
    }
  }

  if(.data$collapse_method == "composite"){
    if(length(.data$intercor) > 1) {
      if(is.null(.data$construct_x) & is.null(.data$construct_y)) {
        stop("Multiple intercorrelations provided without effect-size construct labels.\n",
             "Provide either a scalar intercorrelation or effect size construct labels.")
      }

      intercor_x <- .data$intercor[paste(.data$sample_id[i][1], .data$construct_x[i][1])]
      intercor_y <- .data$intercor[paste(.data$sample_id[i][1], .data$construct_y[i][1])]

      if(is.na(intercor_x)) intercor_x <- .data$intercor[.data$construct_x[i][1]]
      if(is.na(intercor_y)) intercor_y <- .data$intercor[.data$construct_y[i][1]]

      if(is.na(intercor_x)) intercor_x <- .data$intercor[paste(.data$sample_id[i][1], strsplit(x = .data$construct_x[i][1], split = ":")[[1]][1])]
      if(is.na(intercor_y)) intercor_y <- .data$intercor[paste(.data$sample_id[i][1], strsplit(x = .data$construct_y[i][1], split = ":")[[1]][1])]

      if(is.na(intercor_x)) intercor_x <- .data$intercor[strsplit(x = .data$construct_x[i][1], split = ":")[[1]][1]]
      if(is.na(intercor_y)) intercor_y <- .data$intercor[strsplit(x = .data$construct_y[i][1], split = ":")[[1]][1]]

      if(is.na(intercor_x) & is.na(intercor_y)){
        warning("Valid same-construct intercorrelations for constructs '", .data$construct_x[i][1],
                "' and '", .data$construct_y[i][1],
                "' not provided for sample '", .data$sample_id[i][1],
                "': '\n    Computing averages rather than composites", call. = FALSE)
      }else if(is.na(intercor_x) | is.na(intercor_y)){
        if(is.na(intercor_x)){
          warning("Valid same-construct intercorrelations for construct '", .data$construct_x[i][1],
                  "' not provided for sample '", .data$sample_id[i][1],
                  "': '\n     Compositing using information from construct '", .data$construct_y[i][1], "' only", call. = FALSE)
        }else{
          warning("Valid same-construct intercorrelations for construct '", .data$construct_y[i][1],
                  "' not provided for sample '", .data$sample_id[i][1],
                  "': '\n     Compositing using information from construct '", .data$construct_x[i][1], "' only", call. = FALSE)
        }

      }

    } else {
      intercor_x <- intercor_y <- .data$intercor
    }

    if (length(.data$partial_intercor) > 1) {
      if (is.null(.data$construct_y)) {
        stop("Multiple intercorrelations provided without effect-size construct labels.\n",
             "Provide either a scalar intercorrelation or effect size construct labels.")
      }
      partial_y <- .data$partial_intercor[.data$construct_y[i][1]]

      partial_y <- partial_y[paste(.data$sample_id[i][1], .data$construct_y[i][1])]

      if (is.na(partial_y)) partial_y <- partial_y[.data$construct_y[i][1]]
    } else {
      partial_y <- .data$partial_intercor
    }

    if (partial_y) {
      if (!is.null(.data$additional_args$.dx_internal_designation)) {
        intercor_y <- mix_r_2group(rxy = intercor_y, dx = .data$es_data$d, dy = .data$es_data$d, p = .data$es_data$pi)
        partial_y <- FALSE
      }
    }

    if (is.null(.data$measure_x) & is.null(.data$measure_y) & (!is.na(intercor_x) | !is.na(intercor_y))) {
      if (.data$es_metric=="r") {
        es_comp <- composite_r_scalar(mean_rxy = wt_mean(x = .data$es_data$rxyi[i],
                                                         wt = .data$es_data$n_adj[i]),
                                      k_vars_x = length(.data$es_data$rxyi[i]),
                                      mean_intercor_x = mean(c(intercor_x, intercor_y), na.rm = TRUE),
                                      k_vars_y = 1,
                                      mean_intercor_y = intercor_y)
      } else {
        es_comp <- composite_d_scalar(mean_d = wt_mean(x = .data$es_data$d[i],
                                                       wt = .data$es_data$n_adj[i]),
                                      k_vars = length(.data$es_data$dxyi[i]),
                                      mean_intercor = intercor_y,
                                      partial_intercor = partial_y)
      }

      if(.data$ma_method != "bb"){
        rxx_comp <- wt_mean(x = .data$data_x$rxx[i], wt = .data$es_data$n[i])
        ux_comp  <- wt_mean(x = .data$data_x$ux[i],  wt = .data$es_data$n[i])
        ryy_comp <- wt_mean(x = .data$data_y$ryy[i], wt = .data$es_data$n[i])
        uy_comp  <- wt_mean(x = .data$data_y$uy[i],  wt = .data$es_data$n[i])
      }
    } else if (!is.null(.data$measure_x) & is.null(.data$measure_y) & !is.na(intercor_x)) {
      if (.data$es_metric=="r") {
        es_comp <- composite_r_scalar(mean_rxy = wt_mean(x = .data$es_data$rxyi[i],
                                                         wt = .data$es_data$n_adj[i]),
                                      k_vars_x = length(.data$es_data$rxyi[i]),
                                      mean_intercor_x = intercor_x,
                                      k_vars_y = 1,
                                      mean_intercor_y = intercor_y)
      } else {
        es_comp <- composite_d_scalar(mean_d = wt_mean(x = .data$es_data$d[i],
                                                       wt = .data$es_data$n_adj[i]),
                                      k_vars = length(.data$es_data$dxyi[i]),
                                      mean_intercor = intercor_y,
                                      partial_intercor = partial_y)
      }

      if (.data$ma_method != "bb") {
        ryy_comp <- wt_mean(x = .data$data_y$ryy[i], wt = .data$es_data$n[i])
        uy_comp  <- wt_mean(x = .data$data_y$uy[i], wt = .data$es_data$n[i])

        if (.data$es_metric=="r") {
          rxx_comp <- composite_rel_scalar(mean_rel = wt_mean(x = .data$data_x$rxx[i],
                                                              wt = .data$es_data$n[i]),
                                           k_vars = length(.data$es_data$n[i]),
                                           mean_intercor = intercor_x)
          ux_comp  <- composite_u_scalar(mean_u = wt_mean(x = .data$data_x$ux[i],
                                                          wt = .data$es_data$n[i]),
                                         k_vars = length(.data$es_data$n[i]),
                                         mean_ri = intercor_x)
        } else {
          rxx_comp <- wt_mean(x = .data$data_x$rxx[i], wt = .data$es_data$n[i])
          ux_comp  <- wt_mean(x = .data$data_x$ux[i], wt = .data$es_data$n[i])
        }
      }


    } else if (is.null(.data$measure_x) & !is.null(.data$measure_y) & !is.na(intercor_y)) {
      if (.data$es_metric=="r") {
        es_comp <- composite_r_scalar(mean_rxy = wt_mean(x = .data$es_data$rxyi[i],
                                                         wt = .data$es_data$n_adj[i]),
                                      k_vars_x = 1,
                                      mean_intercor_x = intercor_x,
                                      k_vars_y = length(.data$es_data$rxyi[i]),
                                      mean_intercor_y = intercor_y)
      } else {
        es_comp <- composite_d_scalar(mean_d = wt_mean(x = .data$es_data$d[i],
                                                       wt = .data$es_data$n_adj[i]),
                                      k_vars = length(.data$es_data$dxyi[i]),
                                      mean_intercor = intercor_y,
                                      partial_intercor = partial_y)
      }
      if (.data$ma_method != "bb") {
        ryy_comp <- composite_rel_scalar(mean_rel = wt_mean(x = .data$data_y$ryy[i],
                                                            wt = .data$es_data$n[i]),
                                         k_vars = length(.data$es_data$n[i]),
                                         mean_intercor = intercor_y)
        uy_comp  <- composite_u_scalar(mean_u = wt_mean(x = .data$data_y$uy[i],
                                                        wt = .data$es_data$n[i]),
                                       k_vars = length(.data$es_data$n[i]),
                                       mean_ri = intercor_y)
        rxx_comp <- wt_mean(x = .data$data_x$rxx[i], wt = .data$es_data$n[i])
        ux_comp  <- wt_mean(x = .data$data_x$ux[i], wt = .data$es_data$n[i])
      }

    } else if (!is.null(.data$measure_x) & !is.null(.data$measure_y) & !is.na(intercor_x) & !is.na(intercor_y)) {
      kx <- length(unique(.data$measure_x[i]))
      ky <- length(unique(.data$measure_y[i]))

      if (.data$es_metric=="r") {
        es_comp <- composite_r_scalar(mean_rxy = wt_mean(x = .data$es_data$rxyi[i],
                                                         wt = .data$es_data$n_adj[i]),
                                      k_vars_x = kx,
                                      mean_intercor_x = intercor_x,
                                      k_vars_y = ky,
                                      mean_intercor_y = intercor_y)
      } else {
        es_comp <- composite_d_scalar(mean_d = wt_mean(x = .data$es_data$dxyi[i],
                                                       wt = .data$es_data$n_adj[i]),
                                      k_vars = length(.data$es_data$dxyi[i]),
                                      mean_intercor = intercor_y)
      }

      if (.data$ma_method != "bb") {
        ryy_comp <- composite_rel_scalar(mean_rel = wt_mean(x = .data$data_y$ryyi[i],
                                                            wt = .data$es_data$n[i]),
                                         k_vars = ky,
                                         mean_intercor = intercor_y)
        uy_comp  <- composite_u_scalar(mean_u = wt_mean(x = .data$data_y$uy[i],
                                                        wt = .data$es_data$n[i]),
                                       k_vars = ky,
                                       mean_ri = intercor_y)

        if (.data$es_metric=="r") {
          rxx_comp <- composite_rel_scalar(mean_rel = wt_mean(x = .data$data_x$rxxi[i],
                                                              wt = .data$es_data$n[i]),
                                           k_vars = kx,
                                           mean_intercor = intercor_x)
          ux_comp  <- composite_u_scalar(mean_u = wt_mean(x = .data$data_x$ux[i],
                                                          wt = .data$es_data$n[i]),
                                         k_vars = kx,
                                         mean_ri = intercor_x)
        } else {
          rxx_comp <- wt_mean(x = .data$data_x$rxx[i], wt = .data$es_data$n[i])
          ux_comp  <- wt_mean(x = .data$data_x$ux[i], wt = .data$es_data$n[i])
        }
      }
    } else {
      if (.data$es_metric=="r") {
        es_comp <- wt_mean(x = .data$es_data$rxyi[i], wt = .data$es_data$n_adj[i])
      } else {
        es_comp <- wt_mean(x = .data$es_data$dxyi[i], wt = .data$es_data$n_adj[i])
      }

      if (.data$ma_method != "bb") {
        rxx_comp <- wt_mean(x = .data$data_x$rxx[i], wt = .data$es_data$n[i])
        ux_comp  <- wt_mean(x = .data$data_x$ux[i],  wt = .data$es_data$n[i])
        ryy_comp <- wt_mean(x = .data$data_y$ryy[i], wt = .data$es_data$n[i])
        uy_comp  <- wt_mean(x = .data$data_y$uy[i],  wt = .data$es_data$n[i])
      }
    }
  }

  if (.data$ma_method != "bb") {
    k_items_x_comp <- wt_mean(x = .data$data_x$k_items_x[i], wt = .data$es_data$n[i])
    k_items_y_comp  <- wt_mean(x = .data$data_y$k_items_y[i], wt = .data$es_data$n[i])
  }

  if (.data$ma_method == "bb") {
    rxx_comp <- ryy_comp <-
      ux_comp <- uy_comp <-
      rxx_restricted_comp <- ryy_restricted_comp <-
      ux_observed_comp <- uy_observed_comp <-
      correct_rr_x <- correct_rr_y <-
      indirect_rr_x <- indirect_rr_y <-
      k_items_x_comp <- k_items_y_comp <-
      NULL
  }

  n_comp <- wt_mean(x = .data$es_data$n[i], wt = .data$es_data$n_adj[i])
  n_adj_comp <- wt_mean(x = .data$es_data$n_adj[i], wt = .data$es_data$n_adj[i])

  if (abs(es_comp) > 1 && .data$es_metric == "r") {
    stop("The composite correlation for sample ID '",
         .data$es_data$sample_id[i][1],
         "' is not possible (> 1). Please\n",
         "  (a) supply alternative intercorrelations,\n",
         "  (b) supply sample-specific intercorrelations,\n",
         "  (c) change the `collapse_method` argument, or\n",
         "  (d) manually consolidate the dependency among estimates.\n\n",
         "  See `help('control_intercor')` for more details.",
         call. = FALSE)
  }

  if (all(c("d", "n1", "n2", "pi", "pa") %in% colnames(.data$es_data))){
    n1_comp <- wt_mean(x = .data$es_data$n1[i], wt = .data$es_data$n_adj[i])
    n2_comp <- wt_mean(x = .data$es_data$n2[i], wt = .data$es_data$n_adj[i])
    pi_comp <- wt_mean(x = .data$es_data$pi[i], wt = .data$es_data$n_adj[i])
    pa_comp <- wt_mean(x = .data$es_data$pa[i], wt = .data$es_data$n_adj[i])
    d_comp <- convert_r_to_d(r = es_comp, p = pi_comp)
  } else {
    n1_comp <- n2_comp <- pi_comp <- pa_comp <- d_comp <- NULL
  }

  out <- list(sample_id = .data$sample_id[i][1],
              moderators_comp = moderators_comp,
              es_comp = es_comp,
              n_comp = n_comp, n_adj_comp = n_adj_comp,
              rxx_comp = rxx_comp, ryy_comp = ryy_comp,
              ux_comp = ux_comp, uy_comp = uy_comp,
              rxx_restricted_comp = rxx_restricted_comp,
              ryy_restricted_comp = ryy_restricted_comp,
              ux_observed_comp = ux_observed_comp,
              uy_observed_comp = uy_observed_comp,
              k_items_x_comp = k_items_x_comp,
              k_items_y_comp = k_items_y_comp,

              correct_rr_x = correct_rr_x[i][1],
              correct_rr_y = correct_rr_y[i][1],

              indirect_rr_x = indirect_rr_x[i][1],
              indirect_rr_y = indirect_rr_y[i][1],

              d_comp = d_comp,
              n1_comp = n1_comp, n2_comp = n2_comp,
              pi_comp = pi_comp, pa_comp = pa_comp)

  if (!is.null(correct_rr_x)) {
    if (length(correct_rr_x) > 1) {
      out$correct_rr_x <- correct_rr_x[i][1]
    } else {
      out$correct_rr_x <- correct_rr_x
    }
  }

  if (!is.null(correct_rr_y)) {
    if (length(correct_rr_y) > 1) {
      out$correct_rr_y <- correct_rr_y[i][1]
    } else {
      out$correct_rr_y <- correct_rr_y
    }
  }

  if (!is.null(indirect_rr_x)) {
    if (length(indirect_rr_x) > 1) {
      out$indirect_rr_x <- indirect_rr_x[i][1]
    } else {
      out$indirect_rr_x <- indirect_rr_x
    }
  }

  if (!is.null(indirect_rr_y)) {
    if (length(indirect_rr_y) > 1) {
      out$indirect_rr_y <- indirect_rr_y[i][1]
    } else {
      out$indirect_rr_y <- indirect_rr_y
    }
  }

  out$construct_x <- .data$construct_x[i][1]
  out$construct_y <- .data$construct_y[i][1]

  if (!is.null(.data$data_x$rxx_consistency)) out$rxx_consistency <- as.logical(mean(.data$data_x$rxx_consistency[i]))
  if (!is.null(.data$data_y$ryy_consistency)) out$ryy_consistency <- as.logical(mean(.data$data_y$ryy_consistency[i]))

  if (!is.null(.data$data_x$correct_rxx)) out$correct_rxx <- as.logical(mean(.data$data_x$correct_rxx[i]))
  if (!is.null(.data$data_y$correct_ryy)) out$correct_ryy <- as.logical(mean(.data$data_y$correct_ryy[i]))

  if (!is.null(.data$data_x$sign_rxz)) out$sign_rxz <- sign(mean(.data$data_x$sign_rxz[i]))
  if (!is.null(.data$data_y$sign_ryz)) out$sign_ryz <- sign(mean(.data$data_y$sign_ryz[i]))

  if (!is.null(.data$data_x$rxx_type)) out$rxx_type <- convert_consistency2reltype(consistency = out$rxx_consistency)
  if (!is.null(.data$data_y$ryy_type)) out$ryy_type <- convert_consistency2reltype(consistency = out$ryy_consistency)

  out$citekey <- citekey_comp
  out
}



reconcile_artifacts <- function(logic_vec_x = TRUE, logic_vec_y = TRUE, sample_id,
                                art_vec_x, art_vec_y,
                                construct_x = NULL, construct_y = NULL,
                                measure_x = NULL, measure_y = NULL){

     ## First, reconcile logical vectors to ensure that matching study-construct-method combinations agree across entries.
     logic_reconciled <- .reconcile_artifacts(sample_id = sample_id,
                                              art_vec_x = logic_vec_x,
                                              art_vec_y = logic_vec_y,
                                              construct_x = construct_x,
                                              construct_y = construct_y,
                                              measure_x = measure_x,
                                              measure_y = measure_y)
     logic_vec_x <- logic_reconciled$art_vec_x
     logic_vec_y <- logic_reconciled$art_vec_y

     ## Reconcile artifacts that have logical values of TRUE.
     ## Find entries that should have the same value and ensure that they do.
     if(any(c(logic_vec_x, logic_vec_y))){
          art_reconciled <- .reconcile_artifacts(logic_vec_x = logic_vec_x,
                                                 logic_vec_y = logic_vec_y,
                                                 sample_id = sample_id,
                                                 art_vec_x = art_vec_x,
                                                 art_vec_y = art_vec_y,
                                                 construct_x = construct_x,
                                                 construct_y = construct_y,
                                                 measure_x = measure_x,
                                                 measure_y = measure_y)
          art_vec_x <- art_reconciled$art_vec_x
          art_vec_y <- art_reconciled$art_vec_y
     }

     ## Now do the same with artifacts that have logical values of FALSE.
     if(any(!c(logic_vec_x, logic_vec_y))){
          art_reconciled <- .reconcile_artifacts(logic_vec_x = !logic_vec_x,
                                                 logic_vec_y = !logic_vec_y,
                                                 sample_id = sample_id,
                                                 art_vec_x = art_vec_x,
                                                 art_vec_y = art_vec_y,
                                                 construct_x = construct_x,
                                                 construct_y = construct_y,
                                                 measure_x = measure_x,
                                                 measure_y = measure_y)
          art_vec_x <- art_reconciled$art_vec_x
          art_vec_y <- art_reconciled$art_vec_y
     }

     list(art_vec_x = art_vec_x, art_vec_y = art_vec_y, logic_vec_x = logic_vec_x, logic_vec_y = logic_vec_y)
}

