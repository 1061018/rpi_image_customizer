import os
from jinja2 import Template
from template_vars import data
from yaml_reader import YamlParser

FIRST_RUN_J2_PATH = "rpi_image_customizer/src/first_run.sh.j2"

# def verify_condition(name, password, region):
#     if not name and not password and not region:
#         return False
#     if any(value is None or value =="" for value in (name, password, region)):
#         return True


# def assert_configurations(data):
#     if data["enable_ssh"]:
#         if data["ssh_public_key"] and data["ssh_password_authentication"]:
#             raise Exception("You can only have ssh_public_key or ssh_password_authentication, never both at the same time!")

#     # verify user name and password
#     if verify_condition(data["user_name"], data["user_password"], "test"):
#         raise Exception("If you want to set user, you need to set password and vice versa!")

#     # verify if wifi inputs are correct
#     if verify_condition(data["wifi_ssid"], data["wifi_pass"], data["wifi_country"]):
#         raise Exception("You need to check your wifi configuration, something is missing!")


def verify_condition(*args):
    return any(value is None or value == "" for value in args)


def assert_configurations(data):
    # Verifica se as configurações de SSH estão corretas
    if data.get("enable_ssh"):
        if data.get("ssh_public_key") and data.get("ssh_password_authentication"):
            raise Exception(
                "You can only have ssh_public_key or ssh_password_authentication, never both at the same time!"
            )

    # Verifica o nome de usuário e senha
    if verify_condition(data.get("user_name"), data.get("user_password")):
        raise Exception(
            "If you want to set a user, you need to set a password and vice versa!"
        )

    # Verifica se as configurações de Wi-Fi estão corretas
    if verify_condition(
        data.get("wifi_ssid"), data.get("wifi_pass"), data.get("wifi_country")
    ):
        raise Exception(
            "You need to check your wifi configuration, something is missing!"
        )


def main():
    template = Template(open(FIRST_RUN_J2_PATH, encoding="utf-8").read())
    user_config_yaml = YamlParser.load_yaml_file("data_input/default.yaml")

    data["new_hostname"] = os.getenv("HOSTNAME")
    data["user_name"] = os.getenv("NAMEUSER")
    data["user_password"] = os.getenv("NAMEUSERPASSWORD")
    if data["user_name"] and data["user_password"]:
        data["set_user"] = True
    data["ssh_public_key"] = os.getenv("SSHPUBLICKEY")
    data["ssh_password_authentication"] = user_config_yaml.get(
        "ssh_password_authentication", False
    )
    if data["ssh_password_authentication"] or data["ssh_public_key"]:
        data["enable_ssh"] = True
    data["wifi_ssid"] = os.getenv("WIFISSID")
    data["wifi_pass"] = os.getenv("WIFIPASSWORD")
    data["wifi_country"] = user_config_yaml.get("wifi_country")
    data["hidden_ssid"] = user_config_yaml.get("hidden_ssid", data["hidden_ssid"])
    if data["wifi_ssid"] and data["wifi_pass"] and data["wifi_country"]:
        data["enable_wifi"] = True
    data["set_local"] = user_config_yaml.get("set_local")
    data["keyboard"] = user_config_yaml.get("keyboard")
    data["timezone"] = user_config_yaml.get("timezone")

    assert_configurations(data)

    final_script = template.render(data)

    with open("first_run.sh", "w", encoding="utf-8") as f:
        f.write(final_script)


if __name__ == "__main__":
    main()
