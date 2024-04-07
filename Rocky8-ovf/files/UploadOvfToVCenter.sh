#!/bin/bash 
echo "Delete existing OVF template……"
output=$(govc library.ls /${VSPHERE_CONTENT_LIBRARY}/${VM_NAME}-latest)
if [ -n "$output" ]; then
    govc library.rm /${VSPHERE_CONTENT_LIBRARY}/${VM_NAME}-latest
    echo "OVF template has removed."
else
    echo "No OVF template to remove."
fi
echo "Upload OVF to vCenter Content Library"
govc library.import -n ${VM_NAME}-latest ${VSPHERE_CONTENT_LIBRARY} ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
echo "OVF template uploaded successfully"
echo "Destroy virtual machine template……"
govc vm.destroy ${VM_NAME}-${TEMPLATE_VERSION}
echo "Destroy virtual machine template successfully."
