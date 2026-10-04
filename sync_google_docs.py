import os
import pickle
import pandas as pd
from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# Quyền truy cập chỉ đọc cho Google Sheets và Google Docs
SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets.readonly',
    'https://www.googleapis.com/auth/documents.readonly'
]

# ID của tài liệu (Lấy từ URL của Google Sheets và Docs)
# Ví dụ URL: https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
SAMPLE_SPREADSHEET_ID = '13i2ei5PXZwaEKG8XmM147CX5dIHspNT1QPfSn3UrdyI'
SAMPLE_RANGE_NAME = 'Sheet1!A1:E' # Tên sheet và vùng dữ liệu cần lấy

# URL Docs: https://docs.google.com/document/d/195j9e5w-zW50r3234234234234234/edit
SAMPLE_DOCUMENT_ID = '15T162PZ1i0_3RtLhAlcD5fQaHU8ETyP0I1JQx2OmJZg'
def get_credentials():
    creds = None
    # token.pickle lưu trữ access token sau khi bạn đăng nhập lần đầu
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
            
    # Nếu không có token hợp lệ, yêu cầu người dùng đăng nhập
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists('credentials.json'):
                print("LỖI: Không tìm thấy file credentials.json.")
                print("Vui lòng tải credentials.json từ Google Cloud Console và đặt vào thư mục này.")
                return None
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            # Mở trình duyệt để người dùng đăng nhập và xác thực
            creds = flow.run_local_server(port=0)
            
        # Lưu token lại cho các lần chạy sau
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)
            
    return creds

def read_google_sheet(creds):
    try:
        service = build('sheets', 'v4', credentials=creds)
        sheet = service.spreadsheets()
        
        # Tự động lấy tên của Sheet đầu tiên (phòng trường hợp tên là 'Trang tính1' thay vì 'Sheet1')
        sheet_metadata = service.spreadsheets().get(spreadsheetId=SAMPLE_SPREADSHEET_ID).execute()
        first_sheet_title = sheet_metadata.get('sheets', '')[0].get("properties", {}).get("title", "Sheet1")
        dynamic_range = f"{first_sheet_title}!A1:Z"
        
        result = sheet.values().get(spreadsheetId=SAMPLE_SPREADSHEET_ID,
                                    range=dynamic_range).execute()
        values = result.get('values', [])

        if not values:
            print('Không tìm thấy dữ liệu trong Google Sheets.')
            return None
        
        import csv
        with open('thiet_ke_tu_sheets.csv', 'w', newline='', encoding='utf-8-sig') as f:
            writer = csv.writer(f)
            writer.writerows(values)
        
        print("Đã lấy được dữ liệu từ Google Sheets!")
        print("Đã lưu vào thiet_ke_tu_sheets.csv")
        return values
    except Exception as err:
        print(f"Lỗi khi đọc Sheets: {err}")

def read_google_doc(creds):
    try:
        service = build('docs', 'v1', credentials=creds)
        document = service.documents().get(documentId=SAMPLE_DOCUMENT_ID).execute()
        
        # Lấy nội dung text từ cấu trúc JSON phức tạp của Google Docs
        text_content = ""
        for element in document.get('body').get('content'):
            if 'paragraph' in element:
                elements = element.get('paragraph').get('elements')
                for elem in elements:
                    if 'textRun' in elem:
                        text_content += elem.get('textRun').get('content')
                        
        print("Đã lấy được dữ liệu từ Google Docs!")
        # Lưu thành file markdown/text cục bộ cho IDE phân tích
        with open('thiet_ke_tu_docs.md', 'w', encoding='utf-8') as f:
            f.write(text_content)
        print("Đã lưu vào thiet_ke_tu_docs.md")
        return text_content
    except Exception as err:
        print(f"Lỗi khi đọc Docs: {err}")

def main():
    creds = get_credentials()
    if creds:
        print("Tiến hành đọc Google Sheets...")
        read_google_sheet(creds)
        print("\nTiến hành đọc Google Docs...")
        read_google_doc(creds)

if __name__ == '__main__':
    main()
