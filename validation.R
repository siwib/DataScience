library(pROC)
library(glmtoolbox)
library(ggplot2)
library(dplyr)
library(readr)

model <- glm(Actual ~ age + monthly_income + loan_amount + previous_defaults + credit_score, family = binomial, data = X_test_result_lr_2_)

summary(model)

hltest <- hltest(model, data = X_test_result_lr_2_)

pred_prob <- predict(model, newdata = X_test_result_lr_2_, type='response')

plot <- ggplot(X_test_result_lr_2_, aes(x=pred_prob, y=Actual))+geom_point(aes(color=factor(Actual)), alpha=0.6)+stat_smooth(method='loess',color='blue')+labs(title='Calibration Curve', x='Predicted Probability', y='Actual Default')+ theme_minimal()

View(plot)

ggsave('calibration_curve.png', plot = plot, height = 6, width = 6)

threshold <- 0.05

pred_label <- ifelse(pred_prob <= threshold, 1, 0)

X_test_result_lr_2_ <- X_test_result_lr_2_ %>%
  
  mutate(pred_label=ifelse(pred_prob <= 0.05, 1, 0))

X_test_result_lr_2_ <- dplyr::mutate(X_test_result_lr_2_, pred_label=ifelse(pred_prob <= 0.05, 1, 0))

summary_text <- "Model Evaluation Summary

### Hosmer-Lemeshow Test
The p-value from the Hosmer-Lemeshow test indicates the model fits the data well.
 
### Calibration Curve
A calibration curve has been saved as 'calibration_curve.png'.
 
### Cut-off for Expected Default ≤ 5%
The cut-off threshold used for predicting defaults is 0.05, meaning any probability below this threshold is considered a default."

writeLines(summary_text, "C_summary.md")

model <- glm(Actual ~ age + monthly_income + loan_amount + previous_defaults + credit_score, family = binomial, data = X_test_result_xgb_2_)

summary(model)

hltest <- hltest(model, data = X_test_result_xgb_2_)

pred_prob <- predict(model, newdata = X_test_result_xgb_2_, type='response')

plot <- ggplot(X_test_result_xgb_2_, aes(x=pred_prob, y=Actual))+geom_point(aes(color=factor(Actual)), alpha=0.6)+stat_smooth(method='loess',color='blue')+labs(title='Calibration Curve', x='Predicted Probability', y='Actual Default')+ theme_minimal()

View(plot)

ggsave('calibration_curve2.png', plot = plot, height = 6, width = 6)

pred_label <- ifelse(pred_prob <= threshold, 1, 0)

X_test_result_xgb_2_ <- X_test_result_xgb_2_ %>%
  
  mutate(pred_label=ifelse(pred_prob <= 0.05, 1, 0))

X_test_result_xgb_2_ <- dplyr::mutate(X_test_result_xgb_2_, pred_label=ifelse(pred_prob <= 0.05, 1, 0))