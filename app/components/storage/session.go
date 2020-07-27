package storage

import (
	"github.com/badThug/otus-social-network/app/components/config"
	"github.com/gorilla/sessions"
	"net/http"
)

const SessionUserIdKey = "user_id"

type SessionStorage struct {
	config      *config.Config
	CookieStore *sessions.CookieStore
}

func InitSession(config *config.Config) SessionStorage {
	store := sessions.NewCookieStore([]byte(config.Server.SessionKey))

	store.Options = &sessions.Options{
		Domain:   config.Server.Host,
		Path:     "/",
		MaxAge:   3600 * 24 * 7, // 1 week
		HttpOnly: true,
	}

	session := SessionStorage{
		config:      config,
		CookieStore: store,
	}

	return session
}

func (s *SessionStorage) GetSession(r *http.Request) *sessions.Session {
	session, _ := s.CookieStore.Get(r, "_data")

	return session
}

//func (s *SessionStorage) WriteUserId(r *http.Request, userId int) error {
//	session := s.GetSession(r);
//	session.Values[SessionUserIdKey] = userId
//	err := session.CreateDbConnection(r, w)
//
//	return err
//}
