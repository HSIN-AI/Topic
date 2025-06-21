from fastapi import FastAPI
from langchain_core.messages import HumanMessage
from langchain_community.vectorstores import FAISS
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings
from pydantic import BaseModel

app = FastAPI()

embedding = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001",
    google_api_key="AIzaSyAz9R5KgtA1WzjP7MO9vU49FkDi7DiVpi0"
)
db = FAISS.load_local("faiss_tomato", embedding, allow_dangerous_deserialization=True)

llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",
    google_api_key="AIzaSyAz9R5KgtA1WzjP7MO9vU49FkDi7DiVpi0"
)

class QueryRequest(BaseModel):
    query: str

@app.post("/api/py/query")
async def query(request: QueryRequest):
    user_query = request.query

    # 改用 similarity_search_with_score
    results_with_scores = db.similarity_search_with_score(user_query, k=3)
    relevant_docs = [doc for doc, score in results_with_scores]
    scores = [score for doc, score in results_with_scores]

    # 如果有資料
    if relevant_docs:
        context = "\n".join([doc.page_content for doc in relevant_docs])

        # 假設 top-1 相似度距離作為基準
        top_score = scores[0]  # FAISS 是 L2 距離，越小越好

        # 簡單信心轉換：距離 0~1 → 信心 100%~80%，距離 1~2 → 80%~60% ...
        if top_score < 0.5:
            confidence = 0.95
        elif top_score < 1.0:
            confidence = 0.85
        elif top_score < 1.5:
            confidence = 0.75
        else:
            confidence = 0.6

        prompt = (
            f"你是一位番茄栽培專家，以下是與使用者問題相關的資料：\n{context}\n\n"
            f"使用者問題：{user_query}\n\n"
            "請務必根據上述資料回答問題，不可任意推測或補充資料。"
        )
    else:
        confidence = 0.3  # 無資料則信心低
        prompt = (
            f"使用者問題：{user_query}\n\n"
            "目前沒有相關資料可供參考，請依據你訓練中的知識自由回答。"
        )

 
    try:
        response = llm.invoke([HumanMessage(content=prompt)])
        answer = response.content if response and hasattr(response, "content") else "⚠️ 模型未回應任何內容"
    except Exception as e:
        answer = f"❌ 系統錯誤：{str(e)}"
        confidence = 0.0

    return {
        "answer": answer,
        "confidence": round(confidence * 100, 2)
    }

#先啟動虛擬環境 venv\Scripts\activate.bat
#pip install -r requirements.txt 安裝所需套件
#uvicorn main:app --reload 啟動伺服器
#python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload 啟動伺服器另一個方法
#（允許來自所有 IP（區網內設備）訪問你這台電腦的 API）
# http://127.0.0.1:8000/api/py/query

   # {
  # "query": "番茄有什麼營養價值?"
# }
