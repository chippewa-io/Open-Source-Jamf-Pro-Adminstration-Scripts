import re
import os
import xml.dom.minidom

def extract_xml_messages(log_file_path):
    with open(log_file_path, 'r') as file:
        lines = file.readlines()

    xml_messages = []
    xml_message = ""
    in_xml_message = False
    log_line = ""

    for line in lines:
        if re.search(r'MDM message (received|sent) : <\?xml version="1\.0" encoding="UTF-8"\?>', line):
            if in_xml_message:
                xml_message += line.strip()
                if "</plist>" in line:
                    in_xml_message = False
                    xml_messages.append((log_line, xml_message))
                    xml_message = ""
            else:
                log_line = line.strip()
                xml_message = re.search(r'<\?xml version="1\.0" encoding="UTF-8"\?>.*', line).group(0)
                if "</plist>" in line:
                    xml_messages.append((log_line, xml_message))
                    xml_message = ""
                else:
                    in_xml_message = True
        elif in_xml_message:
            xml_message += line.strip()
            if "</plist>" in line:
                in_xml_message = False
                xml_messages.append((log_line, xml_message))
                xml_message = ""

    return xml_messages

def pretty_print_xml(xml_string):
    try:
        parsed_xml = xml.dom.minidom.parseString(xml_string)
        return parsed_xml.toprettyxml(indent="    ")
    except Exception as e:
        return xml_string  # Return the unformatted XML if parsing fails

def main():
    log_file_path = input("Enter the path to the log file: ").strip().strip("'").strip('"')

    while not log_file_path or not os.path.isfile(log_file_path):
        print("Invalid file path. Please try again.")
        log_file_path = input("Enter the path to the log file: ").strip().strip("'").strip('"')

    xml_messages = extract_xml_messages(log_file_path)

    for log_line, message in xml_messages:
        pretty_message = pretty_print_xml(message)
        print(f"Log Line: {log_line}")
        print(f"XML Message:\n{pretty_message}\n")

if __name__ == "__main__":
    main()