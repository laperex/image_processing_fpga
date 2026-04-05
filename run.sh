source .venv/bin/activate

xviv_wrap_top -t ip_rgb_to_hsv ./srcs/rtl/{axi_types,ip_rgb_to_hsv}.sv -o ./srcs/rtl/wrapper
xviv_wrap_top -t ip_inrange ./srcs/rtl/{axi_types,ip_inrange}.sv -o ./srcs/rtl/wrapper

xviv create-ip --ip ip_rgb_to_hsv
xviv create-ip --ip ip_inrange

xviv create-bd --bd bd_image_processing