
oc patch deployment/coco  -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "'true'"}}}}}'
oc patch deployment/wmj  -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "'true'"}}}}}'
oc patch deployment/mms  -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "'true'"}}}}}'
oc patch deployment/apigw  -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "'true'"}}}}}'
oc patch deployment/vuejs  -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "'true'"}}}}}'

