# WTUM_19_2022

_Github for Topic of prioritizing end-stage patients awaiting for transplantation_

## Overview

In the scope of the course Machine Learning Workshop, we would like to perform the analysis and
investigate the possibility of using ML models in the feld of medicine. In detailed, the States currently
adopts Sickest-First Policy, which means for the patients having end-stage disease (e.g: end-stage liver
disease) and requiring transplantation a new organ, there is a formula used to assess the severity of
patients, afterwards, place them on the waiting list. The sicker the patient is, the higher place he/she is
on the waiting list, and when compatible donated organs from deceased donors, sooner that patient will
get transplanted.
In our study, we will place our emphasis for liver transplant. To assess the severity of end-stage liver
patients, physicians in the US are using MELD-Score formula:

<img src="https://render.githubusercontent.com/render/math?math=MELD = 3.78 \times \ln{[Bili(mg/dL)]}  \+ 11.2 \times \ln{[INR]} \+ 9.57 \times \ln{[Creati(mg/dL)]} \Plus 6.43">


where: 
+ Bilirubin: how well liver clears substance “bile”
+ INR: how well liver makes proteins needed for blood to clot
+ Creatinine: how well kidneys work

Thanks to the use of MELD-Score, the instant fruition came to hopitalization system in the US. “The
MELD-based allocation system was immediately successful, leading to first ever reduction in the number
of waiting list candidates and a 15 % reduction of mortality among those on waiting list”, mentioned in
Freeman, R., Wiesner, R., Edwards, E., Harper, A., Merion, R., Wolfe, R.: Results of the first year of
the new liver allocation plan. Liver Transplant, 10, 7-15 (2004).

But the problem locates at the point, the current system of assessing severity in the US is so naive
and easily manipulated by doctors. In addition, the log-transformed values of Bilirubin, INR, Creatinine
at 1 can be problematic, as a large percentage waiting list candidates possess those lab test below this
threshold. And from a very simple model, what we can expect from, correlation between MELD and
outcome may not be equally strong for all patients, and MELD may not accurately reflect the severity
of their conditions.


## ML Models:

**Data set**: Organ Procurement and Transplantation Network (OPTN) Standard Transplant Analysis
and Research (STAR) dataset.

**Target**: Probability of patients dying or becoming unsuitable for transplant within 3 months.

**Metric**:  out-of-sample area under the curve (AUC).

## References:
- Bertsimas, D., Kung, J., Trichakis, N., Wang, Y., Hirose, R., Vagefi, P.: Development and validation of an optimized prediction of mortality for candidates awaiting liver transplantation.Am. J. Transplantat. 19, 1109–1118 (2018)
- Byrd J., Balakrishnan S., Jiang X., Lipton Z.C. (2021): Predicting Mortality in Liver Transplant Candidates. In Shaban-Nejad A., Michalowski M., Buckeridge D.L. (eds) Explainable AI in Healthcare and Medicine. Studies in Computational Intelligence, vol 914. Springer, Cham.
- UNOS.org
