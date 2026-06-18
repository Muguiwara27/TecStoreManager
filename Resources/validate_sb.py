import xml.etree.ElementTree as ET
import sys

def validate_xml(file_path):
    try:
        tree = ET.parse(file_path)
        print("XML is well-formed.")
        
        # Check for missing constraint references
        root = tree.getroot()
        all_ids = set()
        for elem in root.iter():
            if 'id' in elem.attrib:
                all_ids.add(elem.attrib['id'])
                
        # Check constraints
        missing_refs = 0
        for constraint in root.iter('constraint'):
            firstItem = constraint.attrib.get('firstItem')
            secondItem = constraint.attrib.get('secondItem')
            
            if firstItem and firstItem not in all_ids:
                print(f"Missing firstItem: {firstItem}")
                missing_refs += 1
            if secondItem and secondItem not in all_ids:
                print(f"Missing secondItem: {secondItem}")
                missing_refs += 1
                
        if missing_refs == 0:
            print("No missing constraint references found.")
            
    except ET.ParseError as e:
        print(f"XML Parse Error: {e}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    validate_xml(r"c:\Users\chris\OneDrive\Desktop\Multiplataforma\Moviles\TecStoreManager\TecStoreManager\Resources\Main.storyboard")
