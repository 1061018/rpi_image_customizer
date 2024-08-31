"""
Configurations options Yaml File Parser
"""

import pathlib
import yaml


class YamlParser:
    """
    Class designed to parse the setup created by the user in a .yaml file inside /data_input folder
    On object creation specify the path to chosen .yaml file
    as an argument so the constructor populates a class variable
    """

    def __init__(self, file_path: pathlib.Path):
        self.user_config_yaml = self.load_yaml_file(file_path)

    def get_image_path(self) -> str:
        rpi_conf_yaml = self.user_config_yaml["raspberry_py_image"]
        return rpi_conf_yaml

    @staticmethod
    def load_yaml_file(file_path: pathlib.Path) -> yaml:
        with open(file_path, encoding="utf-8") as file:
            return yaml.load(file, Loader=yaml.FullLoader)
