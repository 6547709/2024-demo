#!/bin/bash

#Delete .mf files
rm -f ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.mf
#Output the ovf file for problem analysis.
cat ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
echo "----------------------------------------------------------------------"
#Replace version number
sed "s/@@VERSION@@/${TEMPLATE_VERSION}/g" rocky8.xml.template > rocky8.xml
#Modify the network name in the template to "Networking" to force users to select a network when deploying.
sed -i "s/${VSPHERE_NETWORK}/Network/g" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Add a Deployment options section to the ovf file.
sed -i "/^  <\/References>/r ovf-add-deployselect-1.xml" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Locate the CPU and memory configuration blocks in the template and delete them.
MARKER_LINE=$( sed -n "/^      <\/System>/=" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf)
START_LINE=$(($MARKER_LINE + 1))
END_LINE=$(($MARKER_LINE + 18))
sed -i "${START_LINE},${END_LINE}d"  ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Added CPU and memory deployment option sections to the template.
sed -i "/^      <\/System>/r ovf-add-deployselect-2.xml" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Add Guestinfo to pass an operating system for customization.
sed -i 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
sed -i "/    <ProductSection>/,+2d" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
sed -i "/^    <\/VirtualHardwareSection>/r rocky8.xml" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Delete nvram
sed -i '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Add multi-language support
sed -i "/^  <\/VirtualSystem>/r ovf-add-multi-language.xml" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Delete useless files to ensure there is only one vmdk
sed -i "/^    <File ovf:id=\"file2\".*$/d" ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#Clean up other useless configurations.
sed -i '/vmw:ExtraConfig.*/d' ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
sed -i '/^[  ]*$/d' ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf
#ovftool ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ovf ../output_vsphere/${VM_NAME}-${TEMPLATE_VERSION}.ova
cd ../output_vsphere
#Generate new mf file using openssl
openssl sha1 *.vmdk *.ovf > ${VM_NAME}-${TEMPLATE_VERSION}.mf
#Output the final ovf file for problem analysis.
cat ${VM_NAME}-${TEMPLATE_VERSION}.ovf
ls -alh
echo "----------------------------------------------------------------------"
