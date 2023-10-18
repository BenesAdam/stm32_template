import json
import argparse
import os.path

def generate_c_cpp_properties(include_dirs, defines, template_file):
    with open(template_file, 'r') as template:
        template_data = json.load(template)

    template_data['configurations'][0]['includePath'] =  [os.path.normpath(os.path.join(dir, "**")) for dir in include_dirs.split()]
    template_data['configurations'][0]['defines'] = [f"{define}" for define in defines.split()]

    return json.dumps(template_data, indent=4)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--include_dirs", help="Include directories as a single string")
    parser.add_argument("--defines", help="Defines as a single string")
    parser.add_argument("--template", help="Path to the template JSON file")
    parser.add_argument("--output", help="Output file path")
    args = parser.parse_args()

    c_cpp_properties_json = generate_c_cpp_properties(args.include_dirs, args.defines, args.template)

    if args.output:
        with open(args.output, 'w') as output_file:
            output_file.write(c_cpp_properties_json)
    else:
        print("Error: Output file not specified (use the --output parameter).", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()